# SmartGaurd-EA-v2
---

## ✅ **SmartGuard EA v2.0 – Strategy Overview Report**

### 🎯 **Core Purpose**

SmartGuard EA v2.0 is an MT5 Expert Advisor designed for precision intraday trading using a **tiered execution system**, **multi-timeframe trend confirmation**, **ATR-based TP/SL management**, and **capital-protective filters**.

---

## ⚙️ **Logic Flow**

### 1. **Initialization**

* On start, SmartGuard EA initializes all required indicators:

  * **HalfTrend MA/ATR indicators** for M5, M30, and H1
  * **EMA + RSI indicators** if enabled
  * **ATR handles** for TP/SL and trailing

### 2. **Pre-Trade FilterStack**

Before any trade is considered, a series of strict filters are applied:

* ✅ **Spread Filter:** Rejects trades if spread exceeds `MaxAllowedSpread`
* ✅ **Session Filter (optional):** Limits trading to specified hours
* ✅ **Volatility Filter (optional):** Ensures ATR ≥ `MinATR`
* ✅ **Capital Protector:** Blocks trades during excessive drawdown or equity stress

### 3. **Signal Validator**

Combines **trend logic** from two systems:

#### 📌 A. **HalfTrend Logic (3-TF)**

* MA high/low bands + ATR deviation from **M5, M30, H1**
* All 3 must agree (and be non-zero) to validate the trend:

  * `+1` → Buy trend
  * `-1` → Sell trend
  * `0` → No clear alignment

#### 📌 B. **EMA + RSI Logic (Optional)**

* Buy if:

  * Fast EMA > Slow EMA AND RSI > threshold
* Sell if:

  * Fast EMA < Slow EMA AND RSI < (100 - threshold)

> ✅ **Final Signal Decision:**

* If both HalfTrend and EMA/RSI are active, only matching signals are allowed.
* If only one system is active, its signal is followed.

---

## 🔁 **Trade Execution – Tiered System**

When a valid signal is detected:

### 🧩 Tiered Entries:

4 trades are placed with equal lot sizes:

* **T1 → TP = ATR × 1**
* **T2 → TP = ATR × 2**
* **T3 → TP = ATR × 3**
* **T4 → TP = ATR × 5** (runner with special logic)

### 📉 Stop Loss:

* **ATR-based SL** applied for all trades
* Tier 4 (T4) may optionally use **break-even stop** instead of a fixed SL

---

## 🔄 **Trailing Stop for Tier 4 (Runner)**

* Initiates when profit > `TrailingStartATRMultiplier × ATR`
* SL follows price with a gap of `TrailingGapATRMultiplier × ATR`
* Respects `UseBreakEvenTP_T4` flag to avoid premature trailing

---

## 🛡️ **Capital & Risk Management**

* **RiskPercentPerTrade** dynamically scales lot size
* **InitialLockRatio** helps preserve a portion of equity as untradable
* **Drawdown protection** enforces equity-based trade blocking
* **Cooldown Timer** prevents overtrading via `TradeCooldownSeconds`

---

## 📝 **Efficiency Summary**

SmartGuard EA v2.0 is designed for **stable, filtered, and highly disciplined execution**:

| Feature                 | Purpose                                                        |
| ----------------------- | -------------------------------------------------------------- |
| ✅ 3-TF HalfTrend Signal | Ensures directional alignment across market structure          |
| ✅ ATR Dynamic TP/SL     | Adapts exits to volatility, increasing trade survivability     |
| ✅ Tiered TP Collection  | Locks in partial profits while letting runners ride trend      |
| ✅ Break-even Logic      | Minimizes runner loss without forcing premature exit           |
| ✅ Trailing Stop Control | Efficiently secures gains while avoiding whipsaw               |
| ✅ CapitalGuard Filters  | Avoids poor trades during high-risk or high-cost conditions    |
| ✅ Modular Configuration | Allows rapid optimization for different symbols and strategies |

---

### 📌 **Final Note**

This EA is built to handle **multi-layered confirmations**, **conservative entry filtering**, and **automated profit-securing** mechanisms, making it ideal for optimization and forward testing in volatile, liquid FX markets like EURUSD, GBPUSD, or XAUUSD.

Let me know if you want this exported to PDF or want an optimizer-ready parameter guide next.
