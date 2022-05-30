; ModuleID = 'dax.c'
source_filename = "dax.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

; Function Attrs: nofree norecurse nosync nounwind uwtable
define dso_local void @dax(double* noalias nocapture %0, double %1, double* noalias nocapture readonly %2, i64 %3) local_unnamed_addr #0 {
  %5 = icmp sgt i64 %3, 0
  br i1 %5, label %6, label %72

6:                                                ; preds = %4
  %7 = icmp ult i64 %3, 4
  br i1 %7, label %70, label %8

8:                                                ; preds = %6
  %9 = and i64 %3, -4
  %10 = insertelement <2 x double> poison, double %1, i32 0
  %11 = shufflevector <2 x double> %10, <2 x double> poison, <2 x i32> zeroinitializer
  %12 = insertelement <2 x double> poison, double %1, i32 0
  %13 = shufflevector <2 x double> %12, <2 x double> poison, <2 x i32> zeroinitializer
  %14 = add i64 %9, -4
  %15 = lshr exact i64 %14, 2
  %16 = add nuw nsw i64 %15, 1
  %17 = and i64 %16, 1
  %18 = icmp eq i64 %14, 0
  br i1 %18, label %52, label %19

19:                                               ; preds = %8
  %20 = and i64 %16, 9223372036854775806
  br label %21

21:                                               ; preds = %21, %19
  %22 = phi i64 [ 0, %19 ], [ %49, %21 ]
  %23 = phi i64 [ %20, %19 ], [ %50, %21 ]
  %24 = getelementptr inbounds double, double* %2, i64 %22
  %25 = bitcast double* %24 to <2 x double>*
  %26 = load <2 x double>, <2 x double>* %25, align 8, !tbaa !3
  %27 = getelementptr inbounds double, double* %24, i64 2
  %28 = bitcast double* %27 to <2 x double>*
  %29 = load <2 x double>, <2 x double>* %28, align 8, !tbaa !3
  %30 = fmul <2 x double> %26, %11
  %31 = fmul <2 x double> %29, %13
  %32 = getelementptr inbounds double, double* %0, i64 %22
  %33 = bitcast double* %32 to <2 x double>*
  store <2 x double> %30, <2 x double>* %33, align 8, !tbaa !3
  %34 = getelementptr inbounds double, double* %32, i64 2
  %35 = bitcast double* %34 to <2 x double>*
  store <2 x double> %31, <2 x double>* %35, align 8, !tbaa !3
  %36 = or i64 %22, 4
  %37 = getelementptr inbounds double, double* %2, i64 %36
  %38 = bitcast double* %37 to <2 x double>*
  %39 = load <2 x double>, <2 x double>* %38, align 8, !tbaa !3
  %40 = getelementptr inbounds double, double* %37, i64 2
  %41 = bitcast double* %40 to <2 x double>*
  %42 = load <2 x double>, <2 x double>* %41, align 8, !tbaa !3
  %43 = fmul <2 x double> %39, %11
  %44 = fmul <2 x double> %42, %13
  %45 = getelementptr inbounds double, double* %0, i64 %36
  %46 = bitcast double* %45 to <2 x double>*
  store <2 x double> %43, <2 x double>* %46, align 8, !tbaa !3
  %47 = getelementptr inbounds double, double* %45, i64 2
  %48 = bitcast double* %47 to <2 x double>*
  store <2 x double> %44, <2 x double>* %48, align 8, !tbaa !3
  %49 = add nuw i64 %22, 8
  %50 = add i64 %23, -2
  %51 = icmp eq i64 %50, 0
  br i1 %51, label %52, label %21, !llvm.loop !7

52:                                               ; preds = %21, %8
  %53 = phi i64 [ 0, %8 ], [ %49, %21 ]
  %54 = icmp eq i64 %17, 0
  br i1 %54, label %68, label %55

55:                                               ; preds = %52
  %56 = getelementptr inbounds double, double* %2, i64 %53
  %57 = bitcast double* %56 to <2 x double>*
  %58 = load <2 x double>, <2 x double>* %57, align 8, !tbaa !3
  %59 = getelementptr inbounds double, double* %56, i64 2
  %60 = bitcast double* %59 to <2 x double>*
  %61 = load <2 x double>, <2 x double>* %60, align 8, !tbaa !3
  %62 = fmul <2 x double> %58, %11
  %63 = fmul <2 x double> %61, %13
  %64 = getelementptr inbounds double, double* %0, i64 %53
  %65 = bitcast double* %64 to <2 x double>*
  store <2 x double> %62, <2 x double>* %65, align 8, !tbaa !3
  %66 = getelementptr inbounds double, double* %64, i64 2
  %67 = bitcast double* %66 to <2 x double>*
  store <2 x double> %63, <2 x double>* %67, align 8, !tbaa !3
  br label %68

68:                                               ; preds = %52, %55
  %69 = icmp eq i64 %9, %3
  br i1 %69, label %72, label %70

70:                                               ; preds = %6, %68
  %71 = phi i64 [ 0, %6 ], [ %9, %68 ]
  br label %73

72:                                               ; preds = %73, %68, %4
  ret void

73:                                               ; preds = %70, %73
  %74 = phi i64 [ %79, %73 ], [ %71, %70 ]
  %75 = getelementptr inbounds double, double* %2, i64 %74
  %76 = load double, double* %75, align 8, !tbaa !3
  %77 = fmul double %76, %1
  %78 = getelementptr inbounds double, double* %0, i64 %74
  store double %77, double* %78, align 8, !tbaa !3
  %79 = add nuw nsw i64 %74, 1
  %80 = icmp eq i64 %79, %3
  br i1 %80, label %72, label %73, !llvm.loop !10
}

attributes #0 = { nofree norecurse nosync nounwind uwtable "frame-pointer"="none" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }

!llvm.module.flags = !{!0, !1}
!llvm.ident = !{!2}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"uwtable", i32 1}
!2 = !{!"Ubuntu clang version 13.0.0-2"}
!3 = !{!4, !4, i64 0}
!4 = !{!"double", !5, i64 0}
!5 = !{!"omnipotent char", !6, i64 0}
!6 = !{!"Simple C/C++ TBAA"}
!7 = distinct !{!7, !8, !9}
!8 = !{!"llvm.loop.mustprogress"}
!9 = !{!"llvm.loop.isvectorized", i32 1}
!10 = distinct !{!10, !8, !11, !9}
!11 = !{!"llvm.loop.unroll.runtime.disable"}
