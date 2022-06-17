; ModuleID = 'vec.c'
source_filename = "vec.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

%struct.vec_t = type { double, double }

@__const.main.v1 = private unnamed_addr constant %struct.vec_t { double 1.000000e-01, double 1.000000e-01 }, align 8
@__const.main.v2 = private unnamed_addr constant %struct.vec_t { double 2.000000e-01, double 2.000000e-01 }, align 8
@.str = private unnamed_addr constant [9 x i8] c"%lf %lf\0A\00", align 1

; Function Attrs: noinline nounwind optnone uwtable
define dso_local i32 @main() #0 {
  %1 = alloca %struct.vec_t, align 8
  %2 = alloca %struct.vec_t, align 8
  %3 = alloca %struct.vec_t, align 8
  %4 = alloca %struct.vec_t, align 8
  %5 = bitcast %struct.vec_t* %1 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 8 %5, i8* align 8 bitcast (%struct.vec_t* @__const.main.v1 to i8*), i64 16, i1 false)
  %6 = bitcast %struct.vec_t* %2 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 8 %6, i8* align 8 bitcast (%struct.vec_t* @__const.main.v2 to i8*), i64 16, i1 false)
  %7 = bitcast %struct.vec_t* %1 to { double, double }*
  %8 = getelementptr inbounds { double, double }, { double, double }* %7, i32 0, i32 0
  %9 = load double, double* %8, align 8
  %10 = getelementptr inbounds { double, double }, { double, double }* %7, i32 0, i32 1
  %11 = load double, double* %10, align 8
  %12 = bitcast %struct.vec_t* %2 to { double, double }*
  %13 = getelementptr inbounds { double, double }, { double, double }* %12, i32 0, i32 0
  %14 = load double, double* %13, align 8
  %15 = getelementptr inbounds { double, double }, { double, double }* %12, i32 0, i32 1
  %16 = load double, double* %15, align 8
  %17 = call { double, double } @vec_add(double %9, double %11, double %14, double %16)
  %18 = bitcast %struct.vec_t* %3 to { double, double }*
  %19 = getelementptr inbounds { double, double }, { double, double }* %18, i32 0, i32 0
  %20 = extractvalue { double, double } %17, 0
  store double %20, double* %19, align 8
  %21 = getelementptr inbounds { double, double }, { double, double }* %18, i32 0, i32 1
  %22 = extractvalue { double, double } %17, 1
  store double %22, double* %21, align 8
  %23 = bitcast %struct.vec_t* %1 to i8*
  %24 = bitcast %struct.vec_t* %3 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 8 %23, i8* align 8 %24, i64 16, i1 false)
  %25 = bitcast %struct.vec_t* %1 to { double, double }*
  %26 = getelementptr inbounds { double, double }, { double, double }* %25, i32 0, i32 0
  %27 = load double, double* %26, align 8
  %28 = getelementptr inbounds { double, double }, { double, double }* %25, i32 0, i32 1
  %29 = load double, double* %28, align 8
  %30 = call { double, double } @vec_scale(double %27, double %29, double 2.000000e+00)
  %31 = bitcast %struct.vec_t* %4 to { double, double }*
  %32 = getelementptr inbounds { double, double }, { double, double }* %31, i32 0, i32 0
  %33 = extractvalue { double, double } %30, 0
  store double %33, double* %32, align 8
  %34 = getelementptr inbounds { double, double }, { double, double }* %31, i32 0, i32 1
  %35 = extractvalue { double, double } %30, 1
  store double %35, double* %34, align 8
  %36 = bitcast %struct.vec_t* %1 to i8*
  %37 = bitcast %struct.vec_t* %4 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 8 %36, i8* align 8 %37, i64 16, i1 false)
  %38 = bitcast %struct.vec_t* %1 to { double, double }*
  %39 = getelementptr inbounds { double, double }, { double, double }* %38, i32 0, i32 0
  %40 = load double, double* %39, align 8
  %41 = getelementptr inbounds { double, double }, { double, double }* %38, i32 0, i32 1
  %42 = load double, double* %41, align 8
  %43 = call double @vec_length2(double %40, double %42)
  %44 = getelementptr inbounds %struct.vec_t, %struct.vec_t* %1, i32 0, i32 1
  store double %43, double* %44, align 8
  %45 = getelementptr inbounds %struct.vec_t, %struct.vec_t* %1, i32 0, i32 0
  %46 = load double, double* %45, align 8
  %47 = getelementptr inbounds %struct.vec_t, %struct.vec_t* %1, i32 0, i32 1
  %48 = load double, double* %47, align 8
  %49 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([9 x i8], [9 x i8]* @.str, i64 0, i64 0), double %46, double %48)
  %50 = getelementptr inbounds %struct.vec_t, %struct.vec_t* %2, i32 0, i32 0
  %51 = load double, double* %50, align 8
  %52 = getelementptr inbounds %struct.vec_t, %struct.vec_t* %2, i32 0, i32 1
  %53 = load double, double* %52, align 8
  %54 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([9 x i8], [9 x i8]* @.str, i64 0, i64 0), double %51, double %53)
  ret i32 0
}

; Function Attrs: argmemonly nofree nounwind willreturn
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* noalias nocapture writeonly, i8* noalias nocapture readonly, i64, i1 immarg) #1

; Function Attrs: noinline nounwind optnone uwtable
define internal { double, double } @vec_add(double %0, double %1, double %2, double %3) #0 {
  %5 = alloca %struct.vec_t, align 8
  %6 = alloca %struct.vec_t, align 8
  %7 = alloca %struct.vec_t, align 8
  %8 = bitcast %struct.vec_t* %6 to { double, double }*
  %9 = getelementptr inbounds { double, double }, { double, double }* %8, i32 0, i32 0
  store double %0, double* %9, align 8
  %10 = getelementptr inbounds { double, double }, { double, double }* %8, i32 0, i32 1
  store double %1, double* %10, align 8
  %11 = bitcast %struct.vec_t* %7 to { double, double }*
  %12 = getelementptr inbounds { double, double }, { double, double }* %11, i32 0, i32 0
  store double %2, double* %12, align 8
  %13 = getelementptr inbounds { double, double }, { double, double }* %11, i32 0, i32 1
  store double %3, double* %13, align 8
  %14 = getelementptr inbounds %struct.vec_t, %struct.vec_t* %5, i32 0, i32 0
  %15 = getelementptr inbounds %struct.vec_t, %struct.vec_t* %6, i32 0, i32 0
  %16 = load double, double* %15, align 8
  %17 = getelementptr inbounds %struct.vec_t, %struct.vec_t* %7, i32 0, i32 0
  %18 = load double, double* %17, align 8
  %19 = fadd double %16, %18
  store double %19, double* %14, align 8
  %20 = getelementptr inbounds %struct.vec_t, %struct.vec_t* %5, i32 0, i32 1
  %21 = getelementptr inbounds %struct.vec_t, %struct.vec_t* %6, i32 0, i32 1
  %22 = load double, double* %21, align 8
  %23 = getelementptr inbounds %struct.vec_t, %struct.vec_t* %7, i32 0, i32 1
  %24 = load double, double* %23, align 8
  %25 = fadd double %22, %24
  store double %25, double* %20, align 8
  %26 = bitcast %struct.vec_t* %5 to { double, double }*
  %27 = load { double, double }, { double, double }* %26, align 8
  ret { double, double } %27
}

; Function Attrs: noinline nounwind optnone uwtable
define internal { double, double } @vec_scale(double %0, double %1, double %2) #0 {
  %4 = alloca %struct.vec_t, align 8
  %5 = alloca %struct.vec_t, align 8
  %6 = alloca double, align 8
  %7 = bitcast %struct.vec_t* %5 to { double, double }*
  %8 = getelementptr inbounds { double, double }, { double, double }* %7, i32 0, i32 0
  store double %0, double* %8, align 8
  %9 = getelementptr inbounds { double, double }, { double, double }* %7, i32 0, i32 1
  store double %1, double* %9, align 8
  store double %2, double* %6, align 8
  %10 = getelementptr inbounds %struct.vec_t, %struct.vec_t* %4, i32 0, i32 0
  %11 = getelementptr inbounds %struct.vec_t, %struct.vec_t* %5, i32 0, i32 0
  %12 = load double, double* %11, align 8
  %13 = load double, double* %6, align 8
  %14 = fmul double %12, %13
  store double %14, double* %10, align 8
  %15 = getelementptr inbounds %struct.vec_t, %struct.vec_t* %4, i32 0, i32 1
  %16 = getelementptr inbounds %struct.vec_t, %struct.vec_t* %5, i32 0, i32 1
  %17 = load double, double* %16, align 8
  %18 = load double, double* %6, align 8
  %19 = fmul double %17, %18
  store double %19, double* %15, align 8
  %20 = bitcast %struct.vec_t* %4 to { double, double }*
  %21 = load { double, double }, { double, double }* %20, align 8
  ret { double, double } %21
}

; Function Attrs: noinline nounwind optnone uwtable
define internal double @vec_length2(double %0, double %1) #0 {
  %3 = alloca %struct.vec_t, align 8
  %4 = bitcast %struct.vec_t* %3 to { double, double }*
  %5 = getelementptr inbounds { double, double }, { double, double }* %4, i32 0, i32 0
  store double %0, double* %5, align 8
  %6 = getelementptr inbounds { double, double }, { double, double }* %4, i32 0, i32 1
  store double %1, double* %6, align 8
  %7 = getelementptr inbounds %struct.vec_t, %struct.vec_t* %3, i32 0, i32 0
  %8 = load double, double* %7, align 8
  %9 = getelementptr inbounds %struct.vec_t, %struct.vec_t* %3, i32 0, i32 0
  %10 = load double, double* %9, align 8
  %11 = fmul double %8, %10
  %12 = getelementptr inbounds %struct.vec_t, %struct.vec_t* %3, i32 0, i32 1
  %13 = load double, double* %12, align 8
  %14 = getelementptr inbounds %struct.vec_t, %struct.vec_t* %3, i32 0, i32 1
  %15 = load double, double* %14, align 8
  %16 = fmul double %13, %15
  %17 = fadd double %11, %16
  ret double %17
}

declare dso_local i32 @printf(i8*, ...) #2

attributes #0 = { noinline nounwind optnone uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { argmemonly nofree nounwind willreturn }
attributes #2 = { "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }

!llvm.module.flags = !{!0, !1, !2}
!llvm.ident = !{!3}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"uwtable", i32 1}
!2 = !{i32 7, !"frame-pointer", i32 2}
!3 = !{!"Ubuntu clang version 13.0.1-2ubuntu2"}
