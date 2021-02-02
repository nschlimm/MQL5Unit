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

//+------------------------------------------------------------------+
//| Internal class representing failed test assert
//+------------------------------------------------------------------+
class CFailedAssert: public CObject
  {
private:
   string            m_file;
   int               m_line;
   string            m_result;
public:
                     CFailedAssert(string file, int line);
                    ~CFailedAssert();

   void              Display();

   // Mutators
   void              SetResult(string text);

   // Accessors
   string            GetResult();
  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CFailedAssert::CFailedAssert(string file, int line)
  {
   m_file = file;
   m_line = line;
   m_result = "";
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CFailedAssert::~CFailedAssert()
  {
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CFailedAssert::Display()
  {
   Print("+"+m_file+":"+IntegerToString(m_line)
         +" : "+m_result);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CFailedAssert::SetResult(string text)
  {
   m_result = text;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string CFailedAssert::GetResult()
  {
   return m_result;
  }

//+------------------------------------------------------------------+
//| Collection of test asserts for a specific unit test
//+------------------------------------------------------------------+
class CUnitTestAsserts: public CObject
  {
private:
   string            m_name;
   CList             m_failedAssertsList;
   int               m_candleCount;

   void              AddFailedAssert(string file, int line, string message);

public:
                     CUnitTestAsserts(string testName);
                    ~CUnitTestAsserts();

   // asserts
   bool              IsTrue(string file, int line, bool result);
   bool              IsTrue(string file, int line, int result, int expect);
   bool              IsTrue(string file, int line, string result, string expect);
   bool              IsFalse(string file, int line, bool result);
   bool              IsEquals(string file, int line, string stringA, string stringB);
   bool              IsEquals(string file, int line, int nbrA, int nbrB);
   bool              IsEquals(string file, int line, double nbrA, double nbrB);
   bool              IsNotEquals(string file, int line, double nbrA, double nbrB);
   void              SetFalse(string file, int line, string message);

   // Access to failed asserta
   CFailedAssert*    GetFailedAssert(int position);
   int               TotalFailedTests();
   
   // candle executed
   void              SetCandleCount(int p_candleCount)
                     {
                        m_candleCount = p_candleCount;
                     };

   int              GetCandleCount()
                     {
                        return m_candleCount;
                     };

   // test name
   string            GetTestName();
  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CUnitTestAsserts::CUnitTestAsserts(string testName)
  {
   m_name = testName;
   Print(" active test: "+m_name);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CUnitTestAsserts::~CUnitTestAsserts()
  {
   m_failedAssertsList.Clear();
  }

//+------------------------------------------------------------------+
//| Add a Failed assert to the intern list of failed asserts
//+------------------------------------------------------------------+
void CUnitTestAsserts::AddFailedAssert(string file, int line, string message)
  {
   CFailedAssert *newFailedAssert = new CFailedAssert(file,line);
   newFailedAssert.SetResult(message);
   m_failedAssertsList.Add(newFailedAssert);
  }

//+------------------------------------------------------------------+
//| Assert verifying if the argument is true
//| @param result Boolean to compare
//+------------------------------------------------------------------+
bool CUnitTestAsserts::IsTrue(string file, int line, bool result)
  {
   if(result!=true)
     {
      this.AddFailedAssert(file, line, "isTrue(False)");
      return false;
     }
   else
      return true;
  }

//+------------------------------------------------------------------+
//| Assert verifying if the argument result is as expected
//| @param result Boolean to compare
//+------------------------------------------------------------------+
bool CUnitTestAsserts::IsTrue(string file, int line, int result, int expect)
  {
   if(result!=expect)
     {
      this.AddFailedAssert(file, line, "expected: "+IntegerToString(expect) + " but was " + IntegerToString(result));
      return false;
     }
   else
      return true;
  }

//+------------------------------------------------------------------+
//| Assert verifying if the argument result is as expected
//| @param result Boolean to compare
//+------------------------------------------------------------------+
bool CUnitTestAsserts::IsTrue(string file, int line, string result, string expect)
  {
   if(result!=expect)
     {
      this.AddFailedAssert(file, line, "expected: '"+ expect + "' but was '" + result + "'");
      return false;
     }
   else
      return true;
  }

//+------------------------------------------------------------------+
//| Assert verifying if the argument is true
//| @param result Boolean to compare
//+------------------------------------------------------------------+
bool CUnitTestAsserts::IsFalse(string file, int line, bool result)
  {
   if(result!=false)
     {
      this.AddFailedAssert(file, line, "isFalse(True)");
      return false;
     }
   else
      return true;
  }

//+------------------------------------------------------------------+
//| Assert verifying if the two string arguments are equals
//| @param stringA First string to compare
//| @param stringB Second string to compare
//+------------------------------------------------------------------+
bool CUnitTestAsserts::IsEquals(string file, int line, string stringA,string stringB)
  {
   if(stringA!=stringB)  // If strings are differents
     {
      string message = "IsEquals('"+stringA+"','"+stringB+"')";
      this.AddFailedAssert(file, line, message); // Add a fail test
      return false;
     }
   else
      return true;
  }

//+------------------------------------------------------------------+
//| Assert verifying if the two int arguments are equals
//| @param nbrA First int to compare
//| @param nbrB Second int to compare
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CUnitTestAsserts::IsEquals(string file, int line, int nbrA, int nbrB)
  {
   if(nbrA!=nbrB)  // If strings are differents
     {
      string message = "IsEquals("+IntegerToString(nbrA)+","+IntegerToString(nbrB)+")";
      this.AddFailedAssert(file, line, message); // Add a fail test
      return false;
     }
   else
      return true;
  }

//+------------------------------------------------------------------+
//| Assert verifying if the two double arguments are equals
//| @param nbrA First double to compare
//| @param nbrB Second double to compare
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CUnitTestAsserts::IsEquals(string file, int line, double nbrA, double nbrB)
  {
   if(nbrA!=nbrB)  // If strings are differents
     {
      string message = "IsEquals("+DoubleToString(nbrA)+","+DoubleToString(nbrB)+")";
      this.AddFailedAssert(file, line, message); // Add a fail test
      return false;
     }
   else
      return true;
  }

//+------------------------------------------------------------------+
//| Assert verifying if the two double arguments are not equals
//| @param nbrA First double to compare
//| @param nbrB Second double to compare
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CUnitTestAsserts::IsNotEquals(string file, int line, double nbrA, double nbrB)
  {
   if(nbrA==nbrB)  // If strings are differents
     {
      string message = "IsNotEquals("+DoubleToString(nbrA)+","+DoubleToString(nbrB)+")";
      this.AddFailedAssert(file, line, message); // Add a fail test
      return false;
     }
   else
      return true;
  }

//+------------------------------------------------------------------+
//| Set the assert as false directly for a certain reason
//| @param expected What was expected
//| @param reality What really happen
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CUnitTestAsserts::SetFalse(string file, int line, string message)
  {
   this.AddFailedAssert(file, line, message); // Add a fail test
  }

//+------------------------------------------------------------------+
//| Get the failed asserts by its position in the list
//| @return The failed assert if an assert exists at this position, NULL otherwise
//+------------------------------------------------------------------+
CFailedAssert* CUnitTestAsserts::GetFailedAssert(int position)
  {
   return m_failedAssertsList.GetNodeAtIndex(position);
  }

//+------------------------------------------------------------------+
//| Get the total of failed asserts
//| @return The total of failed tests
//+------------------------------------------------------------------+
int CUnitTestAsserts::TotalFailedTests(void)
  {
   return m_failedAssertsList.Total();
  }

//+------------------------------------------------------------------+
//| Get the name of the test
//| @return The unit test name
//+------------------------------------------------------------------+
string CUnitTestAsserts::GetTestName()
  {
   return m_name;
  }

//+------------------------------------------------------------------+
