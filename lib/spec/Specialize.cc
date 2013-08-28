
#include "llvm/Pass.h"                         
#include "llvm/PassSupport.h"                  
#include "llvm/Support/CommandLine.h"

#include "llvm/Argument.h"                     
#include "llvm/Constants.h"                    
#include "llvm/DerivedTypes.h"                 
#include "llvm/Function.h"                     
#include "llvm/GlobalVariable.h"               
#include "llvm/Instructions.h"                 
#include "llvm/Module.h"
#include "llvm/Support/raw_ostream.h"

#include <stdio.h>
#include <stdint.h>
#include <map>
#include <string>

#include "cake/lstring.h"
#include "cake/spec.h"
#include "cake/util.h"

using namespace llvm;
using namespace std;

cl::opt<string> SpecInfo("spec-info", 
        cl::desc("Spec Info"), 
        cl::value_desc("spec info file"),
        cl::init(""));

cl::opt<string> SpecText("spec-text",
        cl::desc("Spec Text"),
        cl::value_desc("spec spec string"),
        cl::init(""));

cl::opt<string> KernelName("kernel", 
        cl::desc("Kernel Name"), 
        cl::value_desc("name of kernel"),
        cl::init(""));

namespace {
    class Specialize : public ModulePass {
      public:
        static char ID;

        Specialize() : ModulePass(ID) {}

        virtual void getAnalysisUsage(AnalysisUsage &AU) const;
        virtual bool runOnModule(Module &M);
    };
}

char Specialize::ID = 0;

static RegisterPass<Specialize> X("specialize", "Specialize kernel on args");

void
Specialize::getAnalysisUsage(AnalysisUsage& au) const
{
    // Do nothing.
}

static
char*
type_name(Type* tt)
{
    std::string buffer;
    llvm::raw_string_ostream stream(buffer);
    tt->print(stream);
    return lstrdup(stream.str().c_str());
}

bool
Specialize::runOnModule(Module& M)
{

    auto F = M.getFunction(KernelName);

    if (F == 0) {
        carp("No such kernel, giving up.");
    }
    
    /* Read spec.info */
    spec_info* info;
    
    if (SpecText.getValue() != "") {
        printf("Specialize kernel %s with string %s\n",
                KernelName.getValue().c_str(),
                SpecInfo.getValue().c_str());

        int arg_count = F->arg_size();
        char **arg_names = (char**) alloca(arg_count * sizeof(char*));
        int ii = 0;
        for (auto it = F->arg_begin(); it != F->arg_end(); ++it) {
            arg_names[ii] = lstrdup(it->getName().str().c_str());
            ii += 1;
        }
        info = parse_spec_text(arg_names, arg_count, 
                SpecText.getValue().c_str());
    }
   
    if (SpecInfo.getValue() != "") {
        printf("Specialize kernel %s with file %s\n",
                KernelName.getValue().c_str(),
                SpecInfo.getValue().c_str());
     
        info = read_spec_info(SpecInfo.getValue().c_str());
    }

    /* Find function args */ 
    printf("Function args:\n");

    int ii = 0;
    for (auto it = F->arg_begin(); it != F->arg_end(); ++it) {
        spec_arg sa = info->args[ii++];

        Type *tt = it->getType();

        string name(it->getName().str());
        string type(type_name(tt));

        printf(" - Arg %s, type %s\n",
                it->getName().str().c_str(),
                type.c_str());

        if (sa.spec) {
            if (type == "i64") {
                int64_t vv64;
                if (sa.size == sizeof(int64_t))
                    vv64 = *((int64_t*)sa.value);
                else if (sa.size == sizeof(int32_t))
                    vv64 = (int64_t) *((int32_t*)sa.value);
                else
                    carp("Size mismatch");
                printf("   --> Spec as i64 with value %ld\n", vv64);
                Value* sp_vv64 = ConstantInt::getSigned(tt, vv64);
                it->replaceAllUsesWith(sp_vv64);
            }
            else if (type == "i32") {
                assert(sa.size == sizeof(int32_t));
                int32_t vv32 = *((int32_t*)sa.value);
                printf("   --> Spec as i32 with value %d\n", vv32);
                Value* sp_vv32 = ConstantInt::getSigned(tt, vv32);
                it->replaceAllUsesWith(sp_vv32);
            }
            else if (type == "double") {
                assert(sa.size == sizeof(double));
                double vvd = *((double*)sa.value);
                printf("   --> Spec as double with value %.02f\n", vvd);
                Value* spd = ConstantFP::get(tt, vvd);
                it->replaceAllUsesWith(spd);
            }
            else if (type == "float") {
                assert(sa.size == sizeof(float));
                float vvf = *((float*)sa.value);
                printf("   --> Spec as float with value %.02f\n", vvf);
                Value* spf = ConstantFP::get(tt, vvf);
                it->replaceAllUsesWith(spf);
            }
            else {
                char* error_msg = lsprintf(
                        "Can't specialize on a value of type %s.",
                        type.c_str());
                carp(error_msg);
            }
        }
    }

    return false;
}

