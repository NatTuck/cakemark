; ModuleID = 'mmul.ll'
target datalayout = "e-p:32:32:32-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:32:64-f32:32:32-f64:32:64-v64:64:64-v128:128:128-a0:0:64-f80:32:32-n8:16:32-S128"
target triple = "i386-pc-linux-gnu"

define void @mmul(double* %C, double* %A, double* %B, i32 %nn_) nounwind {
  %nn = add i32 256, 0
  br label %1

; <label>:1                                       ; preds = %29, %0
  %ii.0 = phi i32 [ 0, %0 ], [ %30, %29 ]
  %2 = icmp slt i32 %ii.0, %nn
  br i1 %2, label %3, label %31

; <label>:3                                       ; preds = %1
  br label %4

; <label>:4                                       ; preds = %26, %3
  %jj.0 = phi i32 [ 0, %3 ], [ %27, %26 ]
  %5 = icmp slt i32 %jj.0, %nn
  br i1 %5, label %6, label %28

; <label>:6                                       ; preds = %4
  br label %7

; <label>:7                                       ; preds = %20, %6
  %sum.0 = phi double [ 0.000000e+00, %6 ], [ %19, %20 ]
  %kk.0 = phi i32 [ 0, %6 ], [ %21, %20 ]
  %8 = icmp slt i32 %kk.0, %nn
  br i1 %8, label %9, label %22

; <label>:9                                       ; preds = %7
  %10 = mul nsw i32 %nn, %ii.0
  %11 = add nsw i32 %10, %kk.0
  %12 = getelementptr inbounds double* %A, i32 %11
  %13 = load double* %12
  %14 = mul nsw i32 %nn, %kk.0
  %15 = add nsw i32 %14, %jj.0
  %16 = getelementptr inbounds double* %B, i32 %15
  %17 = load double* %16
  %18 = fmul double %13, %17
  %19 = fadd double %sum.0, %18
  br label %20

; <label>:20                                      ; preds = %9
  %21 = add nsw i32 %kk.0, 1
  br label %7

; <label>:22                                      ; preds = %7
  %23 = mul nsw i32 %nn, %ii.0
  %24 = add nsw i32 %23, %jj.0
  %25 = getelementptr inbounds double* %C, i32 %24
  store double %sum.0, double* %25
  br label %26

; <label>:26                                      ; preds = %22
  %27 = add nsw i32 %jj.0, 1
  br label %4

; <label>:28                                      ; preds = %4
  br label %29

; <label>:29                                      ; preds = %28
  %30 = add nsw i32 %ii.0, 1
  br label %1

; <label>:31                                      ; preds = %1
  ret void
}
