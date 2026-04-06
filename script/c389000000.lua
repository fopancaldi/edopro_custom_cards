--Pot of Benevolence
local s, id = GetID()

function s.initial_effect(c)
  --Activate
  local e1 = Effect.CreateEffect(c)
  e1:SetCategory(CATEGORY_DRAW)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetCode(EVENT_FREE_CHAIN)
  e1:SetCountLimit(1, id, EFFECT_COUNT_CODE_OATH)
  e1:SetCondition(s.condition)
  e1:SetTarget(s.target)
  e1:SetOperation(s.activate)
  c:RegisterEffect(e1)
end

function s.condition(_, tp, _, _, _, _, _, _)
  return Duel.GetFieldGroupCount(tp, LOCATION_EXTRA, 0) == 0
end

function s.target(_, tp, _, _, _, _, _, _, chk)
  if chk == 0 then
    return Duel.IsPlayerCanDraw(tp, 2)
  end
  Duel.SetTargetPlayer(tp)
  Duel.SetTargetParam(2)
  Duel.SetOperationInfo(0, CATEGORY_DRAW, nil, 0, tp, 2)
end

function s.activate(_, _, _, _, _, _, _, _)
  local p, d = Duel.GetChainInfo(0, CHAININFO_TARGET_PLAYER, CHAININFO_TARGET_PARAM)
  Duel.Draw(p, d, REASON_EFFECT)
end
