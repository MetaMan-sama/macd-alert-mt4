# MACD Alert — MQL4 Script

A MetaTrader 4 script that monitors three independent **MACD signal events** simultaneously — MACD line crossovers of the signal line, and MACD histogram sign changes in both directions — using three persistent global state variables (`PrevMACDLine`, `PrevSignalLine`, `PrevHistogram`) to enforce strict prior-cycle comparison logic, and dispatching a rich multi-value alert message that includes the MACD line, signal line, and histogram values on every trigger.

---

## Overview

The Moving Average Convergence Divergence indicator, developed by Gerald Appel in the 1970s, remains one of the most widely used momentum indicators in technical analysis. It consists of three components: the MACD line (fast EMA minus slow EMA), the signal line (EMA of the MACD line), and the histogram (MACD line minus signal line). Each component generates distinct signal types. The MACD/signal crossover is the primary entry signal: when the MACD line crosses above the signal line, bullish momentum is building; when it crosses below, bearish momentum is building. The histogram complements this by showing the rate of change of the crossover — a histogram turning from negative to positive signals that the bearish pressure is waning before the lines actually cross, while a histogram turning from positive to negative warns of softening bullish momentum. This script monitors all three simultaneously in a single loop, giving traders comprehensive real-time MACD coverage across all standard signal types.

---

## Features

- **Three concurrent signal monitors:**
  - **MACD/signal crossover** — `PrevMACDLine <= PrevSignalLine && macdLine > signalLine` → Bullish; `PrevMACDLine >= PrevSignalLine && macdLine < signalLine` → Bearish
  - **Histogram turned positive** — `PrevHistogram <= 0 && histogram > 0` → **MACD Histogram Turned Positive**
  - **Histogram turned negative** — `PrevHistogram >= 0 && histogram < 0` → **MACD Histogram Turned Negative**
- **Histogram derived manually** — `histogram = macdLine − signalLine` computed each cycle rather than using `MODE_HIST` directly, matching the standard histogram definition
- **Previous-value state tracking** — `PrevMACDLine`, `PrevSignalLine`, and `PrevHistogram` globals updated unconditionally at cycle end; `<=` / `>=` equality guards prevent false triggers on flat MACD states
- **Rich alert message** — `AlertMACD()` formats with MACD line, signal line, and histogram all included via `"MACD Line: %.5f, Signal Line: %.5f, Histogram: %.5f"` for complete context
- **Fully configurable MACD parameters** — `FastEMA`, `SlowEMA`, and `SignalSMA` independently adjustable; defaults match Gerald Appel's original `12/26/9` specification
- **Three notification channels:** sound alert, email, and mobile push
- **Lightweight loop** — polls once per minute (`Sleep(60000)`)

---

## How It Works

1. Every minute, `iMACD()` is called twice: `MODE_MAIN` for `macdLine`, `MODE_SIGNAL` for `signalLine`; `histogram = macdLine − signalLine`
2. Three conditions evaluated using prior-cycle globals:
   - Crossover: `PrevMACDLine <= PrevSignalLine && macdLine > signalLine` → Bullish; reverse → Bearish
   - Histogram flip positive: `PrevHistogram <= 0 && histogram > 0`
   - Histogram flip negative: `PrevHistogram >= 0 && histogram < 0`
3. All three state globals updated at cycle end

---

## Input Parameters

| Parameter      | Type            | Default     | Description                                    |
|----------------|-----------------|-------------|------------------------------------------------|
| `TradeSymbol`  | string          | `EURUSD`    | Symbol for analysis                            |
| `Timeframe`    | ENUM_TIMEFRAMES | `PERIOD_H1` | Timeframe for analysis                         |
| `FastEMA`      | int             | `12`        | Fast EMA period for MACD line construction     |
| `SlowEMA`      | int             | `26`        | Slow EMA period for MACD line construction     |
| `SignalSMA`    | int             | `9`         | Signal line smoothing period                   |
| `EnableAlerts` | bool            | `true`      | Fire an on-screen/sound alert                  |
| `EnableEmail`  | bool            | `false`     | Send an email notification                     |
| `EnablePush`   | bool            | `false`     | Send a mobile push notification                |

---

## Alert Message Format

```
Bullish MACD Crossover detected on EURUSD (Timeframe: PERIOD_H1)
MACD Line: 0.00042, Signal Line: 0.00038, Histogram: 0.00004
```

---

## Installation

1. Copy `MACD__Moving_Average_Convergence_Divergence__001.mq4` to `MQL4/Scripts/`
2. Compile in MetaEditor (F7)
3. Drag onto any chart from Navigator → Scripts
4. Configure inputs and click **OK**

---

## Requirements

- MetaTrader 4 (`#property strict` compatible build)
- MQL4 compiler (MetaEditor)

---

## License

MIT License

Copyright (c) 2026

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
