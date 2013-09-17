#include <stdio.h>
#include <stdlib.h>

#include <CL/cl.h>

#include "cl_simple.h"

int main(int argc, char ** argv)
{
   struct cl_simple_context context;

   unsigned i;
   int * out;
   unsigned out_size;
   size_t global_work_size = 16;
   size_t local_work_size  = 16;

   if (argc > 1)
       global_work_size = atoi(argv[1]);

   if (argc > 2)
       local_work_size = atoi(argv[2]);

   out_size = global_work_size * sizeof(int);
   out = malloc(out_size);

   if (!out) {
      return EXIT_FAILURE;
   }

   if (!clSimpleSimpleInit(&context, "global_id")) {
      return EXIT_FAILURE;
   }

   if (!clSimpleSetOutputBuffer(&context, out_size)) {
      return EXIT_FAILURE;
   }

   if(!clSimpleEnqueueNDRangeKernel(context.command_queue,
                              context.kernel,
                              1, &global_work_size, &global_work_size)) {
      return EXIT_FAILURE;
   }

   if (!clSimpleReadOutput(&context, out, out_size)) {
      return EXIT_FAILURE;
   }

   /* Print the result */
   for (i = 0; i < global_work_size; i++) {
      fprintf(stderr, "id %u = %u\n", i, out[i]);
   }

   /* Check the result */
   for (i = 0; i < global_work_size; i++) {
      if (i != out[i]) {
         fprintf(stderr, "Expected out[%u] = %u, actual: %u\n", i, i, out[i]);
         return EXIT_FAILURE;
      }
   }

   return EXIT_SUCCESS;
}
