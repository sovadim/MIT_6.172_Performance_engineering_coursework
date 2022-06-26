; ModuleID = 'fib.c'
source_filename = "fib.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

; Function Attrs: nofree nosync nounwind readnone uwtable
define dso_local i64 @fib(i64 %0) local_unnamed_addr #0 {
  %2 = icmp slt i64 %0, 2
  br i1 %2, label %11, label %3

3:                                                ; preds = %1, %3
  %4 = phi i64 [ %8, %3 ], [ %0, %1 ]
  %5 = phi i64 [ %9, %3 ], [ 0, %1 ]
  %6 = add nsw i64 %4, -1
  %7 = tail call i64 @fib(i64 %6)
  %8 = add nsw i64 %4, -2
  %9 = add nsw i64 %7, %5
  %10 = icmp slt i64 %4, 4
  br i1 %10, label %11, label %3

11:                                               ; preds = %3, %1
  %12 = phi i64 [ 0, %1 ], [ %9, %3 ]
  %13 = phi i64 [ %0, %1 ], [ %8, %3 ]
  %14 = add nsw i64 %13, %12
  ret i64 %14
}

attributes #0 = { nofree nosync nounwind readnone uwtable "frame-pointer"="none" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }

!llvm.module.flags = !{!0, !1}
!llvm.ident = !{!2}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"uwtable", i32 1}
!2 = !{!"Ubuntu clang version 13.0.0-2"}
