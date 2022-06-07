; ModuleID = 'example2.c'
source_filename = "example2.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

; Function Attrs: nofree nosync nounwind uwtable
define dso_local void @test(i8* noalias %0, i8* noalias %1) local_unnamed_addr #0 !dbg !8 {
  call void @llvm.dbg.value(metadata i8* %0, metadata !19, metadata !DIExpression()), !dbg !26
  call void @llvm.dbg.value(metadata i8* %1, metadata !20, metadata !DIExpression()), !dbg !26
  call void @llvm.assume(i1 true) [ "align"(i8* %0, i64 16) ], !dbg !27
  call void @llvm.dbg.value(metadata i8* %0, metadata !19, metadata !DIExpression()), !dbg !26
  call void @llvm.assume(i1 true) [ "align"(i8* %1, i64 16) ], !dbg !28
  call void @llvm.dbg.value(metadata i8* %1, metadata !20, metadata !DIExpression()), !dbg !26
  call void @llvm.dbg.value(metadata i64 0, metadata !21, metadata !DIExpression()), !dbg !29
  br label %3, !dbg !30

3:                                                ; preds = %57, %2
  %4 = phi i64 [ 0, %2 ], [ %58, %57 ], !dbg !31
  %5 = getelementptr inbounds i8, i8* %1, i64 %4, !dbg !31
  %6 = bitcast i8* %5 to <8 x i8>*, !dbg !33
  %7 = load <8 x i8>, <8 x i8>* %6, align 8, !dbg !33, !tbaa !36
  %8 = getelementptr inbounds i8, i8* %0, i64 %4, !dbg !31
  %9 = bitcast i8* %8 to <8 x i8>*, !dbg !39
  %10 = load <8 x i8>, <8 x i8>* %9, align 8, !dbg !39, !tbaa !36
  %11 = icmp ugt <8 x i8> %7, %10, !dbg !40
  %12 = extractelement <8 x i1> %11, i32 0, !dbg !40
  br i1 %12, label %13, label %15, !dbg !31

13:                                               ; preds = %3
  %14 = extractelement <8 x i8> %7, i32 0, !dbg !40
  store i8 %14, i8* %8, align 8, !dbg !40, !tbaa !36
  br label %15

15:                                               ; preds = %13, %3
  %16 = extractelement <8 x i1> %11, i32 1, !dbg !40
  br i1 %16, label %17, label %21, !dbg !40

17:                                               ; preds = %15
  %18 = or i64 %4, 1, !dbg !31
  %19 = getelementptr inbounds i8, i8* %0, i64 %18, !dbg !31
  %20 = extractelement <8 x i8> %7, i32 1, !dbg !40
  store i8 %20, i8* %19, align 1, !dbg !40, !tbaa !36
  br label %21

21:                                               ; preds = %17, %15
  %22 = extractelement <8 x i1> %11, i32 2, !dbg !40
  br i1 %22, label %23, label %27, !dbg !40

23:                                               ; preds = %21
  %24 = or i64 %4, 2, !dbg !31
  %25 = getelementptr inbounds i8, i8* %0, i64 %24, !dbg !31
  %26 = extractelement <8 x i8> %7, i32 2, !dbg !40
  store i8 %26, i8* %25, align 2, !dbg !40, !tbaa !36
  br label %27

27:                                               ; preds = %23, %21
  %28 = extractelement <8 x i1> %11, i32 3, !dbg !40
  br i1 %28, label %29, label %33, !dbg !40

29:                                               ; preds = %27
  %30 = or i64 %4, 3, !dbg !31
  %31 = getelementptr inbounds i8, i8* %0, i64 %30, !dbg !31
  %32 = extractelement <8 x i8> %7, i32 3, !dbg !40
  store i8 %32, i8* %31, align 1, !dbg !40, !tbaa !36
  br label %33

33:                                               ; preds = %29, %27
  %34 = extractelement <8 x i1> %11, i32 4, !dbg !40
  br i1 %34, label %35, label %39, !dbg !40

35:                                               ; preds = %33
  %36 = or i64 %4, 4, !dbg !31
  %37 = getelementptr inbounds i8, i8* %0, i64 %36, !dbg !31
  %38 = extractelement <8 x i8> %7, i32 4, !dbg !40
  store i8 %38, i8* %37, align 4, !dbg !40, !tbaa !36
  br label %39

39:                                               ; preds = %35, %33
  %40 = extractelement <8 x i1> %11, i32 5, !dbg !40
  br i1 %40, label %41, label %45, !dbg !40

41:                                               ; preds = %39
  %42 = or i64 %4, 5, !dbg !31
  %43 = getelementptr inbounds i8, i8* %0, i64 %42, !dbg !31
  %44 = extractelement <8 x i8> %7, i32 5, !dbg !40
  store i8 %44, i8* %43, align 1, !dbg !40, !tbaa !36
  br label %45

45:                                               ; preds = %41, %39
  %46 = extractelement <8 x i1> %11, i32 6, !dbg !40
  br i1 %46, label %47, label %51, !dbg !40

47:                                               ; preds = %45
  %48 = or i64 %4, 6, !dbg !31
  %49 = getelementptr inbounds i8, i8* %0, i64 %48, !dbg !31
  %50 = extractelement <8 x i8> %7, i32 6, !dbg !40
  store i8 %50, i8* %49, align 2, !dbg !40, !tbaa !36
  br label %51

51:                                               ; preds = %47, %45
  %52 = extractelement <8 x i1> %11, i32 7, !dbg !40
  br i1 %52, label %53, label %57, !dbg !40

53:                                               ; preds = %51
  %54 = or i64 %4, 7, !dbg !31
  %55 = getelementptr inbounds i8, i8* %0, i64 %54, !dbg !31
  %56 = extractelement <8 x i8> %7, i32 7, !dbg !40
  store i8 %56, i8* %55, align 1, !dbg !40, !tbaa !36
  br label %57

57:                                               ; preds = %53, %51
  %58 = add nuw i64 %4, 8, !dbg !31
  %59 = icmp eq i64 %58, 65536, !dbg !31
  br i1 %59, label %60, label %3, !dbg !31, !llvm.loop !41

60:                                               ; preds = %57
  ret void, !dbg !45
}

; Function Attrs: inaccessiblememonly mustprogress nofree nosync nounwind willreturn
declare void @llvm.assume(i1 noundef) #1

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare void @llvm.dbg.value(metadata, metadata, metadata) #2

attributes #0 = { nofree nosync nounwind uwtable "frame-pointer"="none" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { inaccessiblememonly mustprogress nofree nosync nounwind willreturn }
attributes #2 = { nofree nosync nounwind readnone speculatable willreturn }

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!3, !4, !5, !6}
!llvm.ident = !{!7}

!0 = distinct !DICompileUnit(language: DW_LANG_C99, file: !1, producer: "Ubuntu clang version 13.0.0-2", isOptimized: true, runtimeVersion: 0, emissionKind: FullDebug, enums: !2, splitDebugInlining: false, nameTableKind: None)
!1 = !DIFile(filename: "example2.c", directory: "/home/sovadim/workspace/MIT_6.172_Performance_engineering_coursework/hw3_Vectorization/recitation")
!2 = !{}
!3 = !{i32 7, !"Dwarf Version", i32 4}
!4 = !{i32 2, !"Debug Info Version", i32 3}
!5 = !{i32 1, !"wchar_size", i32 4}
!6 = !{i32 7, !"uwtable", i32 1}
!7 = !{!"Ubuntu clang version 13.0.0-2"}
!8 = distinct !DISubprogram(name: "test", scope: !1, file: !1, line: 9, type: !9, scopeLine: 10, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !18)
!9 = !DISubroutineType(types: !10)
!10 = !{null, !11, !11}
!11 = !DIDerivedType(tag: DW_TAG_restrict_type, baseType: !12)
!12 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !13, size: 64)
!13 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint8_t", file: !14, line: 24, baseType: !15)
!14 = !DIFile(filename: "/usr/include/x86_64-linux-gnu/bits/stdint-uintn.h", directory: "")
!15 = !DIDerivedType(tag: DW_TAG_typedef, name: "__uint8_t", file: !16, line: 38, baseType: !17)
!16 = !DIFile(filename: "/usr/include/x86_64-linux-gnu/bits/types.h", directory: "")
!17 = !DIBasicType(name: "unsigned char", size: 8, encoding: DW_ATE_unsigned_char)
!18 = !{!19, !20, !21}
!19 = !DILocalVariable(name: "a", arg: 1, scope: !8, file: !1, line: 9, type: !11)
!20 = !DILocalVariable(name: "b", arg: 2, scope: !8, file: !1, line: 9, type: !11)
!21 = !DILocalVariable(name: "i", scope: !22, file: !1, line: 14, type: !23)
!22 = distinct !DILexicalBlock(scope: !8, file: !1, line: 14, column: 5)
!23 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint64_t", file: !14, line: 27, baseType: !24)
!24 = !DIDerivedType(tag: DW_TAG_typedef, name: "__uint64_t", file: !16, line: 45, baseType: !25)
!25 = !DIBasicType(name: "long unsigned int", size: 64, encoding: DW_ATE_unsigned)
!26 = !DILocation(line: 0, scope: !8)
!27 = !DILocation(line: 11, column: 9, scope: !8)
!28 = !DILocation(line: 12, column: 9, scope: !8)
!29 = !DILocation(line: 0, scope: !22)
!30 = !DILocation(line: 14, column: 5, scope: !22)
!31 = !DILocation(line: 14, column: 37, scope: !32)
!32 = distinct !DILexicalBlock(scope: !22, file: !1, line: 14, column: 5)
!33 = !DILocation(line: 17, column: 13, scope: !34)
!34 = distinct !DILexicalBlock(scope: !35, file: !1, line: 17, column: 13)
!35 = distinct !DILexicalBlock(scope: !32, file: !1, line: 15, column: 5)
!36 = !{!37, !37, i64 0}
!37 = !{!"omnipotent char", !38, i64 0}
!38 = !{!"Simple C/C++ TBAA"}
!39 = !DILocation(line: 17, column: 20, scope: !34)
!40 = !DILocation(line: 17, column: 18, scope: !34)
!41 = distinct !{!41, !30, !42, !43, !44}
!42 = !DILocation(line: 21, column: 5, scope: !22)
!43 = !{!"llvm.loop.mustprogress"}
!44 = !{!"llvm.loop.isvectorized", i32 1}
!45 = !DILocation(line: 22, column: 1, scope: !8)
