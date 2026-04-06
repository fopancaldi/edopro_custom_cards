--Pot of Acquisitiveness
local s, id = GetID()

function s.initial_effect(c)
  --Activate
  local e1 = Effect.CreateEffect(c)
  e1:SetCategory(CATEGORY_TODECK + CATEGORY_DRAW)
  e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetCode(EVENT_FREE_CHAIN)
  e1:SetCountLimit(1, id, EFFECT_COUNT_CODE_OATH)
  e1:SetTarget(s.target)
  e1:SetOperation(s.activate)
  c:RegisterEffect(e1)
end

function s.target_filter(c, tp)
  return c:IsFaceup() and c:IsControler(tp) and c:IsAbleToDeck()
end

function s.sent_filter(c, tp)
  return c:IsLocation(LOCATION_DECK) and c:IsControler(tp)
end

function s.target(_, tp, _, _, _, _, _, _, chk, chkc)
  if chkc then
    return chkc:IsLocation(LOCATION_REMOVED) and s.target_filter(chkc, tp)
  end
  if chk == 0 then
    return Duel.IsPlayerCanDraw(tp, 1)
      and Duel.IsExistingTarget(s.target_filter, tp, LOCATION_REMOVED, LOCATION_REMOVED, 5, nil, tp)
  end
  Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
  local g = Duel.SelectTarget(tp, s.target_filter, tp, LOCATION_REMOVED, LOCATION_REMOVED, 5, 5, nil, tp)
  Duel.SetOperationInfo(0, CATEGORY_TODECK, g, #g, 0, 0)
  Duel.SetOperationInfo(0, CATEGORY_DRAW, nil, 0, tp, 2)
end

function s.activate(e, tp, _, _, _, _, _, _)
  local tg = Duel.GetChainInfo(0, CHAININFO_TARGET_CARDS)
  if not tg or tg:FilterCount(Card.IsRelateToEffect, nil, e) ~= 5 then
    return
  end
  Duel.SendtoDeck(tg, nil, SEQ_DECKTOP, REASON_EFFECT)
  local g = Duel.GetOperatedGroup()
  if g:IsExists(s.sent_filter, 1, nil, tp) then
    Duel.ShuffleDeck(tp)
  end
  local ct = g:FilterCount(Card.IsLocation, nil, LOCATION_DECK | LOCATION_EXTRA)
  if ct == 5 then
    Duel.BreakEffect()
    Duel.Draw(tp, 2, REASON_EFFECT)
  end
end
