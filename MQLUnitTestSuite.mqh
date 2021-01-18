//+------------------------------------------------------------------+
//|                                                          MQLUnit |
//|                                   Copyright 2021, Niklas Schlimm |
//|                             https://github.com/nschlimm/MQL5Unit |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Niklas Schlimm"
#property link      "https://github.com/nschlimm/MQL5Unit"
#property version   "1.00"

#include <Object.mqh>
#include <Arrays\List.mqh>
#include "MQLUnitTestAsserts.mqh"

enum ENUM_TEST_EXEC_STATE
  {
   PENDING,
   EXECUTED
  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
typedef CUnitTestAsserts*(*UnitTest)();
typedef void(*Setup)();

//+------------------------------------------------------------------+
//| Suite of unit tests
//+------------------------------------------------------------------+
class CUnitTestSuite: public CObject
  {
private:
   CList             m_unitTestsAssertList;

   UnitTest          m_unitTestFunc_OnInit[];
   UnitTest          m_unitTestFunc_OnNewCandle[];
   int               m_ExecuteOnCandleCount[][2]; // holds canlde count on which to execute test and execution status
   Setup             m_setupFunc_OnNewCandle[];
   int               m_SetupExecuteOnCandleCount[][2]; // holds canlde count on which to setup function and execution status

   void              DisplayResults();
   bool              CanFinish(int currentCandleCount);
   void              FinishUnitTestsuite();
   bool              NotEmpty();
public:
   void              AddUnitTestAsserts(CUnitTestAsserts* ut); // result of old school unit test function
   void              AddUnitTestFunction(UnitTest testFunc); // new school test added
   void              AddUnitTestFunction(int onCandleCount, UnitTest testFunc); // new school add on tick test
   void              AddSetupFunction(int onCandleCount, Setup setup); // new school on tick test with setup
   void              ExecuteOnInitTests();
   void              ExecuteNewCandleTests(int currentCandleCount);
   void              ExecuteSetup(int currentCandleCount);

                     CUnitTestSuite();
  };


//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CUnitTestSuite::CUnitTestSuite()
  {
   Print(" --- Unit Tests beginning -------------------------------");
  }

//+------------------------------------------------------------------+
//| Method to display test results                                   |
//+------------------------------------------------------------------+
void CUnitTestSuite::DisplayResults()
  {
   CFailedAssert *failedAssert;
   CUnitTestAsserts* asserts  = m_unitTestsAssertList.GetFirstNode();
   int countOfAsserts = m_unitTestsAssertList.Total();
   int total;
   string summary;

   for(int i = 0; i < countOfAsserts; i++)  // For all unit tests
     {
      total = asserts.TotalFailedTests();

      if(total!=0)  // If there is a failed test
        {
         summary += "F ";
         Print(asserts.GetTestName()+" failed");

         for(int j = 0; j < total; j++)
           {
            failedAssert = asserts.GetFailedAssert(j);
            failedAssert.Display();
           }
        }
      else
        {
         summary += "OK ";
         Print(asserts.GetTestName()+" OK");
        }

      asserts = m_unitTestsAssertList.GetNextNode();
     }

   Print(" --------------------------------------------------------");
   Print(summary);
  }

//+------------------------------------------------------------------+
//| Add an asserts list to the collection of unit test asserts
//+------------------------------------------------------------------+
void CUnitTestSuite::AddUnitTestAsserts(CUnitTestAsserts* ut)
  {
   m_unitTestsAssertList.Add(ut);
  }

//+------------------------------------------------------------------+
//| Add a unit test function to the suite, that executes OnInit                          
//+------------------------------------------------------------------+
void CUnitTestSuite::AddUnitTestFunction(UnitTest testFunc)
  {
   ArrayResize(m_unitTestFunc_OnInit,ArraySize(m_unitTestFunc_OnInit)+1);
   m_unitTestFunc_OnInit[ArraySize(m_unitTestFunc_OnInit)-1] = testFunc;
  }

//+------------------------------------------------------------------+
//| Add a unit test function to the suite that executes on open of
//| specific new candle
//+------------------------------------------------------------------+
void CUnitTestSuite::AddUnitTestFunction(int onCandleCount, UnitTest testFunc)
  {
   ArrayResize(m_unitTestFunc_OnNewCandle,ArraySize(m_unitTestFunc_OnNewCandle)+1);
   ArrayResize(m_ExecuteOnCandleCount,ArrayRange(m_ExecuteOnCandleCount,0)+1);
   int index = ArraySize(m_unitTestFunc_OnNewCandle)-1;
   m_unitTestFunc_OnNewCandle[index] = testFunc;
   m_ExecuteOnCandleCount[index][0] = onCandleCount;
   m_ExecuteOnCandleCount[index][1] = PENDING;
  }

//+------------------------------------------------------------------+
//| Add a setup function for a specific test that executes on open
//| of a specific candle
//+------------------------------------------------------------------+
void CUnitTestSuite::AddSetupFunction(int onCandleCount, Setup setup)
  {
   ArrayResize(m_setupFunc_OnNewCandle,ArraySize(m_setupFunc_OnNewCandle)+1);
   ArrayResize(m_SetupExecuteOnCandleCount,ArrayRange(m_SetupExecuteOnCandleCount,0)+1);
   int index = ArraySize(m_setupFunc_OnNewCandle)-1;
   m_setupFunc_OnNewCandle[index] = setup;
   m_SetupExecuteOnCandleCount[index][0] = onCandleCount;
   m_SetupExecuteOnCandleCount[index][1] = PENDING;
  }

//+------------------------------------------------------------------+
//| Executes the setup functions defined to run on open of specified
//| candle
//+------------------------------------------------------------------+
void CUnitTestSuite::ExecuteSetup(int currentCandleCount)
  {
   for(int i = 0; i < ArraySize(m_setupFunc_OnNewCandle); i++)
     {
      if(currentCandleCount == m_SetupExecuteOnCandleCount[i][0]
         && m_SetupExecuteOnCandleCount[i][1] == PENDING)
        {
         Setup setup = m_setupFunc_OnNewCandle[i];
         setup();
         m_SetupExecuteOnCandleCount[i][1] = EXECUTED;
        }
     }
  }

//+------------------------------------------------------------------+
//| Executes the unit tests of the OnInit phase
//+------------------------------------------------------------------+
void CUnitTestSuite::ExecuteOnInitTests(void)
  {
   for(int i = 0; i < ArraySize(m_unitTestFunc_OnInit); i++)
     {
      UnitTest test = m_unitTestFunc_OnInit[i];
      m_unitTestsAssertList.Add(test());
     }
  }

//+------------------------------------------------------------------+
//| Executes unit tests that are supposed to run on open of a 
//| specific candle
//+------------------------------------------------------------------+
void CUnitTestSuite::ExecuteNewCandleTests(int currentCandleCount)
  {
   for(int i = 0; i < ArraySize(m_unitTestFunc_OnNewCandle); i++)
     {
      if(currentCandleCount == m_ExecuteOnCandleCount[i][0]
         && m_ExecuteOnCandleCount[i][1] == PENDING)
        {
         UnitTest test = m_unitTestFunc_OnNewCandle[i];
         m_unitTestsAssertList.Add(test());
         m_ExecuteOnCandleCount[i][1] = EXECUTED;
        }
     }
   if(CanFinish(currentCandleCount)&&NotEmpty())
      FinishUnitTestsuite();
  }

//+------------------------------------------------------------------+
//| Find out if test suite is empty
//+------------------------------------------------------------------+
bool CUnitTestSuite::NotEmpty()
  {
   return ArraySize(m_unitTestFunc_OnNewCandle)>0;
  }

//+------------------------------------------------------------------+
//| Find out if there are tests left for candles after current
//| candle count. If no tests are pending, suite can finish.
//+------------------------------------------------------------------+
bool CUnitTestSuite::CanFinish(int currentCandleCount)
  {
   for(int i = 0; i<ArraySize(m_unitTestFunc_OnNewCandle); i++)
     {
      ENUM_TEST_EXEC_STATE status = m_ExecuteOnCandleCount[i][1];
      if(status == PENDING)
        {
         return false;
        }
     }
   return true;
  }

//+------------------------------------------------------------------+
//| Finish the test suite and display results
//+------------------------------------------------------------------+
void CUnitTestSuite::FinishUnitTestsuite()
  {
   Print(" --- Unit Tests end -------------------------------------");
   DisplayResults();

// Clear the lists
   m_unitTestsAssertList.Clear();
   ArrayFree(m_unitTestFunc_OnInit);
   ArrayFree(m_unitTestFunc_OnNewCandle);
   ArrayFree(m_ExecuteOnCandleCount);
   ArrayFree(m_setupFunc_OnNewCandle);
   ArrayFree(m_SetupExecuteOnCandleCount);

  }
//+------------------------------------------------------------------+
