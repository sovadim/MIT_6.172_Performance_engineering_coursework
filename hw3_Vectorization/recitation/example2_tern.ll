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

3:                                                ; preds = %3, %2
  %4 = phi i64 [ 0, %2 ], [ %42, %3 ], !dbg !31
  %5 = getelementptr inbounds i8, i8* %1, i64 %4, !dbg !31
  %6 = bitcast i8* %5 to <16 x i8>*, !dbg !33
  %7 = load <16 x i8>, <16 x i8>* %6, align 16, !dbg !33, !tbaa !35
  %8 = getelementptr inbounds i8, i8* %5, i64 16, !dbg !33
  %9 = bitcast i8* %8 to <16 x i8>*, !dbg !33
  %10 = load <16 x i8>, <16 x i8>* %9, align 16, !dbg !33, !tbaa !35
  %11 = getelementptr inbounds i8, i8* %0, i64 %4, !dbg !31
  %12 = bitcast i8* %11 to <16 x i8>*, !dbg !38
  %13 = load <16 x i8>, <16 x i8>* %12, align 16, !dbg !38, !tbaa !35
  %14 = getelementptr inbounds i8, i8* %11, i64 16, !dbg !38
  %15 = bitcast i8* %14 to <16 x i8>*, !dbg !38
  %16 = load <16 x i8>, <16 x i8>* %15, align 16, !dbg !38, !tbaa !35
  %17 = icmp ugt <16 x i8> %7, %13, !dbg !39
  %18 = icmp ugt <16 x i8> %10, %16, !dbg !39
  %19 = select <16 x i1> %17, <16 x i8> %7, <16 x i8> %13, !dbg !40
  %20 = select <16 x i1> %18, <16 x i8> %10, <16 x i8> %16, !dbg !40
  %21 = bitcast i8* %11 to <16 x i8>*, !dbg !41
  store <16 x i8> %19, <16 x i8>* %21, align 16, !dbg !41, !tbaa !35
  %22 = bitcast i8* %14 to <16 x i8>*, !dbg !41
  store <16 x i8> %20, <16 x i8>* %22, align 16, !dbg !41, !tbaa !35
  %23 = or i64 %4, 32, !dbg !31
  %24 = getelementptr inbounds i8, i8* %1, i64 %23, !dbg !31
  %25 = bitcast i8* %24 to <16 x i8>*, !dbg !33
  %26 = load <16 x i8>, <16 x i8>* %25, align 16, !dbg !33, !tbaa !35
  %27 = getelementptr inbounds i8, i8* %24, i64 16, !dbg !33
  %28 = bitcast i8* %27 to <16 x i8>*, !dbg !33
  %29 = load <16 x i8>, <16 x i8>* %28, align 16, !dbg !33, !tbaa !35
  %30 = getelementptr inbounds i8, i8* %0, i64 %23, !dbg !31
  %31 = bitcast i8* %30 to <16 x i8>*, !dbg !38
  %32 = load <16 x i8>, <16 x i8>* %31, align 16, !dbg !38, !tbaa !35
  %33 = getelementptr inbounds i8, i8* %30, i64 16, !dbg !38
  %34 = bitcast i8* %33 to <16 x i8>*, !dbg !38
  %35 = load <16 x i8>, <16 x i8>* %34, align 16, !dbg !38, !tbaa !35
  %36 = icmp ugt <16 x i8> %26, %32, !dbg !39
  %37 = icmp ugt <16 x i8> %29, %35, !dbg !39
  %38 = select <16 x i1> %36, <16 x i8> %26, <16 x i8> %32, !dbg !40
  %39 = select <16 x i1> %37, <16 x i8> %29, <16 x i8> %35, !dbg !40
  %40 = bitcast i8* %30 to <16 x i8>*, !dbg !41
  store <16 x i8> %38, <16 x i8>* %40, align 16, !dbg !41, !tbaa !35
  %41 = bitcast i8* %33 to <16 x i8>*, !dbg !41
  store <16 x i8> %39, <16 x i8>* %41, align 16, !dbg !41, !tbaa !35
  %42 = add nuw nsw i64 %4, 64, !dbg !31
  %43 = icmp eq i64 %42, 65536, !dbg !31
  br i1 %43, label %44, label %3, !dbg !31, !llvm.loop !42

44:                                               ; preds = %3
  ret void, !dbg !46
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
!33 = !DILocation(line: 17, column: 17, scope: !34)
!34 = distinct !DILexicalBlock(scope: !32, file: !1, line: 15, column: 5)
!35 = !{!36, !36, i64 0}
!36 = !{!"omnipotent char", !37, i64 0}
!37 = !{!"Simple C/C++ TBAA"}
!38 = !DILocation(line: 17, column: 24, scope: !34)
!39 = !DILocation(line: 17, column: 22, scope: !34)
!40 = !DILocation(line: 17, column: 16, scope: !34)
!41 = !DILocation(line: 17, column: 14, scope: !34)
!42 = distinct !{!42, !30, !43, !44, !45}
!43 = !DILocation(line: 18, column: 5, scope: !22)
!44 = !{!"llvm.loop.mustprogress"}
!45 = !{!"llvm.loop.isvectorized", i32 1}
!46 = !DILocation(line: 19, column: 1, scope: !8)
