//+------------------------------------------------------------------+
//|                       MACDAlert.mq4                              |
//| Alerts for MACD line crossing Signal line and histogram changes  |
//+------------------------------------------------------------------+
#property strict

// Input parameters
input string TradeSymbol = "EURUSD";         // Symbol for analysis
input ENUM_TIMEFRAMES Timeframe = PERIOD_H1; // Timeframe for analysis
input int FastEMA = 12;                      // Fast EMA period
input int SlowEMA = 26;                      // Slow EMA period
input int SignalSMA = 9;                     // Signal SMA period
input bool EnableAlerts = true;              // Enable sound alerts
input bool EnableEmail = false;              // Enable email notifications
input bool EnablePush = false;               // Enable push notifications

// Global variables for tracking the previous state
double PrevMACDLine = 0.0;
double PrevSignalLine = 0.0;
double PrevHistogram = 0.0;

//+------------------------------------------------------------------+
//| Main Function                                                    |
//+------------------------------------------------------------------+
void OnStart()
{
   Print("MACD Alert Script Started.");

   while (!IsStopped()) {
      // Get current MACD values
      double macdLine = iMACD(TradeSymbol, Timeframe, FastEMA, SlowEMA, SignalSMA, PRICE_CLOSE, MODE_MAIN, 0);
      double signalLine = iMACD(TradeSymbol, Timeframe, FastEMA, SlowEMA, SignalSMA, PRICE_CLOSE, MODE_SIGNAL, 0);
      double histogram = macdLine - signalLine;

      // Get previous values
      PrevMACDLine = iMACD(TradeSymbol, Timeframe, FastEMA, SlowEMA, SignalSMA, PRICE_CLOSE, MODE_MAIN, 1);
      PrevSignalLine = iMACD(TradeSymbol, Timeframe, FastEMA, SlowEMA, SignalSMA, PRICE_CLOSE, MODE_SIGNAL, 1);
      PrevHistogram = PrevMACDLine - PrevSignalLine;

      // Check for MACD line crossing Signal line
      if (PrevMACDLine <= PrevSignalLine && macdLine > signalLine) {
         AlertMACD("Bullish MACD Crossover", macdLine, signalLine, histogram, TradeSymbol, Timeframe);
      } else if (PrevMACDLine >= PrevSignalLine && macdLine < signalLine) {
         AlertMACD("Bearish MACD Crossover", macdLine, signalLine, histogram, TradeSymbol, Timeframe);
      }

      // Check for histogram turning positive or negative
      if (PrevHistogram <= 0 && histogram > 0) {
         AlertMACD("MACD Histogram Turned Positive", macdLine, signalLine, histogram, TradeSymbol, Timeframe);
      } else if (PrevHistogram >= 0 && histogram < 0) {
         AlertMACD("MACD Histogram Turned Negative", macdLine, signalLine, histogram, TradeSymbol, Timeframe);
      }

      Sleep(60000); // Wait 1 minute before checking again
   }
}

//+------------------------------------------------------------------+
//| Send MACD alerts                                                 |
//+------------------------------------------------------------------+
void AlertMACD(string alertType, double macdLine, double signalLine, double histogram, string symbol, ENUM_TIMEFRAMES timeframe)
{
   string message = StringFormat(
      "%s detected on %s (Timeframe: %s)\nMACD Line: %.5f, Signal Line: %.5f, Histogram: %.5f",
      alertType, symbol, EnumToString(timeframe), macdLine, signalLine, histogram
   );

   if (EnableAlerts) Alert(message);
   if (EnableEmail) SendMail("MACD Alert", message);
   if (EnablePush) SendNotification(message);

   Print(message);
}

