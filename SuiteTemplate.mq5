//+------------------------------------------------------------------+
//|                                                          MQLUnit |
//|                                   Copyright 2021, Niklas Schlimm |
//|                             https://github.com/nschlimm/MQL5Unit |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Niklas Schlimm"
#property version   "1.00"

#include "MQLUnitTestLibrary.mqh"
// include the class under test

// add local test state, e.g. object of class under test

//+------------------------------------------------------------------+
//| Standard testsuite method implemented by user                    |
//+------------------------------------------------------------------+
CUnitTestSuite* ComposeTestsuite()
  {
   CUnitTestSuite* testSuite = new CUnitTestSuite();
   // add setup methods using testSuite.AddSetupFunction()
   // add unit tests using testSuite.AddUnitTestFunction(); pass testfunctions as parameter
   return testSuite;
  }

// add test functions, that return an instance of CUnitTestAsserts

//+------------------------------------------------------------------+
