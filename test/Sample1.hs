{-# LANGUAGE QuasiQuotes #-}

module Sample1 where

import           Text.RawString.QQ

sample1 :: [String]
sample1 = lines [r|
global-max-good.c
global-max-good.ppc.o
global-max-good.ppc.exe
global-max-good.ppc.expected
global-max-good.x86.exe
global-max-good.x86.expected
jumpfar.c
jumpfar.h
jumpfar.ppc.exe
jumpfar.ppc.expected
jumpfar.x86.exe
jumpfar.x86.expected
looping.c
looping.ppc.exe
looping.ppc.expected
looping.x86.exe
looping.x86.expected
Makefile
README.org
switching.c
switching.h
switching.hh
switching_llvm.c
switching_llvm.h
switching_llvm.x86.exe
switching_many.c
switching_many_llvm.c
switching_many_llvm.x86.exe
switching_many.ppc.exe
switching.ppc.base-expected
switching.ppc.o
switching.ppc.other
switching.ppc.exe
switching.x86.base-expected
switching.x86.exe
switching-refined.x86.o
switching.x86.orig
switching.x86.refined-expected
switching.x86.refined-expected-orig
switching.x86.refined-last-actual
tailrecurse.c
tailrecurse.expected
tailrecurse.expected.expected
tailrecurse.food.expected
tailrecurse.ppc.exe
tailrecurse.x86.exe
tailrecurse.x86.expected
|]