//+------------------------------------------------------------------+
//|                        SmartGuardCore.mq5                        |
//|     SmartGuard EA v2.0 – Hybrid Strategy w/ HalfTrend + EMA     |
//|                        Developed by Nasib Mohammad               |
//+------------------------------------------------------------------+
#property strict

#include "StrategyConfig.mqh"
#include "EntryLogic.mqh"
#include "HalfTrendLogic.mqh"
#include "SignalValidator.mqh"
#include "FilterStack.mqh"
#include "CapitalProtector.mqh"
#include "VolumeManager.mqh"
#include "TradeManager.mqh"
#include "TrailingStopManager.mqh"

//--- State
bool EA_Active = true;
datetime lastTradeTime = 0;

//+------------------------------------------------------------------+
//| Initialization                                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   Print("🚀 SmartGuard EA v2.0 Initialized – Hybrid Strategy Active");

   InitAll(); // ⬅ Unified init
   EA_Active = true;

   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Tick Execution                                                   |
//+------------------------------------------------------------------+
void OnTick()
{
   if (!EA_Active) return;

   double equity = AccountInfoDouble(ACCOUNT_EQUITY);
   double locked = GetLockedCapital();

   // 🛡️ Capital floor enforcement
   if (equity < locked)
   {
      PrintFormat("🔐 Equity %.2f < Locked Capital %.2f → Trading paused", equity, locked);
      return;
   }

   // 📉 Max Drawdown Protection
   if (IsDrawdownLimitBreached(MaxDrawdownPercent))
   {
      Print("🛑 Max drawdown breached – trading halted.");
      return;
   }

   // 🔁 Update dynamic capital lock
   UpdateCapitalProtector();

   // 📋 Market filters (spread/session/volatility)
   if (!FiltersPass())
   {
      Print("⛔ Filter blocked. Tick skipped.");
      ManageTrailingStop();
      return;
   }

   // ✅ Entry Signal Check (EMA+RSI AND HalfTrend)
   int signal = ValidateEntrySignal();
   if (signal == 0)
   {
      Print("🟡 No valid entry signal.");
      ManageTrailingStop();
      return;
   }

   // 🧊 Cooldown check
   if ((TimeCurrent() - lastTradeTime) < TradeCooldownSeconds)
   {
      Print("⏳ Cooldown active. Skipping.");
      ManageTrailingStop();
      return;
   }

   // 🧱 Prevent stacking
   if (PositionsTotal() > 0)
   {
      Print("⚠️ Existing positions found. Skipping new entry.");
      ManageTrailingStop();
      return;
   }

   // 💰 Unlocked capital = equity - locked capital
   double unlocked = equity - locked;
   if (unlocked <= 0.0)
   {
      PrintFormat("⚠️ No unlocked capital available: %.2f", unlocked);
      ManageTrailingStop();
      return;
   }

   // 🧮 Calculate lot size
   double lotSize = CalculateLotSize(unlocked);
   double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);

   if (lotSize < minLot)
   {
      PrintFormat("⚠️ Lot %.2f < Min %.2f → Using min lot", lotSize, minLot);
      lotSize = minLot;
   }

   // 🚀 Execute Tiered Trades
   ExecuteTieredTrades(signal, lotSize);
   lastTradeTime = TimeCurrent(); // ⏱️ Reset cooldown

   // 🌀 Manage trailing stop
   ManageTrailingStop();
}

//+------------------------------------------------------------------+
//| Deinitialization                                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   DeinitAll(); // ⬅ Unified cleanup
   Print("🟨 SmartGuard EA v2.0 deinitialized. Reason: ", reason);
}

//+------------------------------------------------------------------+
//| Modular Lifecycle                                                |
//+------------------------------------------------------------------+
void InitAll()
{
   InitCapitalProtector(InitialDeposit * InitialLockRatio);
   InitEntryLogicIndicators();
   InitFilterIndicators();
   InitVolumeIndicators();
   InitTradeIndicators();
   InitTrailingIndicators();
}

void DeinitAll()
{
   DeinitEntryLogicIndicators();
   DeinitFilterIndicators();
   DeinitVolumeIndicators();
   DeinitTradeIndicators();
   DeinitTrailingIndicators();
}
