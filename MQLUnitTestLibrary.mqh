//+------------------------------------------------------------------+
//|                                                          MQLUnit |
//|                                   Copyright 2021, Niklas Schlimm |
//|                             https://github.com/nschlimm/MQL5Unit |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Niklas Schlimm"
#property link      "https://github.com/nschlimm/MQL5Unit"
#property version   "1.00"

//+------------------------------------------------------------------+
//| Inclusions
//+------------------------------------------------------------------+

#include "MQLUnitTestAsserts.mqh"
#include "MQLUnitTestSuite.mqh"

datetime candleOpenTime;
int candleCounter = 0;

CUnitTestSuite* m_testSuite;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void IncremetCandleCounter()
  {
   datetime candleOpenTimeCheck = iTime(_Symbol, PERIOD_CURRENT,0);
   if(candleOpenTime!=candleOpenTimeCheck)
     {
      //Print("new candle at: " + candleOpenTimeCheck);
      candleOpenTime = candleOpenTimeCheck;
      candleCounter++;
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {

   IncremetCandleCounter();
   m_testSuite.executeSetup(candleCounter);
   m_testSuite.executeOnNewCandleTests(candleCounter);

  }

void OnInit() {
   m_testSuite = ComposeTestsuite();
}
//+------------------------------------------------------------------+
