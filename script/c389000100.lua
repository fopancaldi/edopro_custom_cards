--Foolish Burial
local s, id = GetID()

function s.initial_effect(c)
  --Send 1 monster to the GY
  local e1 = Effect.CreateEffect(c)
  e1:SetCategory(CATEGORY_REMOVE + CATEGORY_TOGRAVE)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetCode(EVENT_FREE_CHAIN)
  e1:SetCountLimit(1, id, EFFECT_COUNT_CODE_OATH)
  e1:SetCost(s.cost)
  e1:SetTarget(s.target)
  e1:SetOperation(s.activate)
  c:RegisterEffect(e1)
end

function s.cost(e, tp, _, _, _, _, _, _, chk)
  local c = e:GetHandler()
  if chk == 0 then
    return Duel.IsExistingMatchingCard(Card.IsAbleToRemoveAsCost, tp, LOCATION_HAND, 0, 1, c)
  end
  Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_REMOVE)
  local g = Duel.SelectMatchingCard(tp, Card.IsAbleToRemoveAsCost, tp, LOCATION_HAND, 0, 1, 1, c)
  Duel.Remove(g, POS_FACEDOWN, REASON_COST)
end

function s.target_filter(c)
  return c:IsMonster() and c:IsAbleToGrave()
end

function s.target(_, tp, _, _, _, _, _, _, chk)
  if chk == 0 then
    return Duel.IsExistingMatchingCard(s.target_filter, tp, LOCATION_DECK, 0, 1, nil)
  end
  Duel.SetOperationInfo(0, CATEGORY_TOGRAVE, nil, 1, tp, LOCATION_DECK)
end

function s.activate(_, tp, _, _, _, _, _, rp)
  Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
  local g = Duel.SelectMatchingCard(tp, s.target_filter, tp, LOCATION_DECK, 0, 1, 1, nil)
  if #g > 0 then
    Duel.SendtoGrave(g, REASON_EFFECT)
  end
end
