--Draco Awakening
local s, id = GetID()
function s.initial_effect(c)
  --Search on activation
  local e1 = Effect.CreateEffect(c)
  e1:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetCode(EVENT_FREE_CHAIN)
  e1:SetCountLimit(1, id, EFFECT_COUNT_CODE_OATH)
  e1:SetCost(s.track_activation)
  e1:SetTarget(s.search_target)
  e1:SetOperation(s.activate)
  c:RegisterEffect(e1)
  --Tribute summon
  local e2 = Effect.CreateEffect(c)
  e2:SetDescription(aux.Stringid(id, 1))
  e2:SetCategory(CATEGORY_SUMMON)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetRange(LOCATION_SZONE)
  e2:SetCountLimit(1, { id, 1 })
  e2:SetTarget(s.summon_target)
  e2:SetOperation(s.summon_operation)
  c:RegisterEffect(e2)
  --Destroy 1 card on the field
  local e3 = Effect.CreateEffect(c)
  e3:SetDescription(aux.Stringid(id, 2))
  e3:SetCategory(CATEGORY_DESTROY)
  e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_F)
  e3:SetProperty(EFFECT_FLAG_CARD_TARGET + EFFECT_FLAG_DELAY)
  e3:SetCode(EVENT_TO_GRAVE)
  e3:SetCountLimit(1, { id, 2 })
  e3:SetCondition(s.destruction_condition)
  e3:SetTarget(s.destruction_target)
  e3:SetOperation(s.destruction_operation)
  c:RegisterEffect(e3)
end

s.listed_series = { SET_TRUE_DRACO_KING, SET_DRACOSLAYER, SET_DRACOVERLORD }

function s.track_activation(e, _, _, _, _, _, _, _, chk)
  if chk == 0 then
    return true
  end
  e:GetHandler():RegisterFlagEffect(id, RESET_PHASE | PHASE_END, EFFECT_FLAG_OATH, 1)
end

function s.search_filter(c)
  return (
    (c:IsSetCard(SET_TRUE_DRACO_KING) and c:IsMonster())
    or (c:IsSetCard({ SET_DRACOSLAYER, SET_DRACOVERLORD }) and c:IsPendulumMonster())
  ) and c:IsAbleToHand()
end

function s.search_target(_, tp, _, _, _, _, _, _, chk)
  if chk == 0 then
    return Duel.IsExistingMatchingCard(s.search_filter, tp, LOCATION_DECK, 0, 1, nil)
  end
  Duel.SetPossibleOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
end

function s.activate(_, tp, _, _, _, _, _, _)
  local g = Duel.GetMatchingGroup(s.search_filter, tp, LOCATION_DECK, 0, nil)
  if #g > 0 and Duel.SelectYesNo(tp, aux.Stringid(id, 0)) then
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local sc = g:Select(tp, 1, 1, nil):GetFirst()
    if Duel.SendtoHand(sc, nil, REASON_EFFECT) > 0 and sc:IsLocation(LOCATION_HAND) then
      Duel.ConfirmCards(1 - tp, sc)
    end
  end
end

function s.summon_filter(c)
  return c:IsSetCard(SET_TRUE_DRACO_KING) and c:IsSummonable(true, nil, 1)
end

function s.summon_target(e, tp, _, _, _, _, _, _, chk)
  if chk == 0 then
    return Duel.IsExistingMatchingCard(s.summon_filter, tp, LOCATION_HAND, 0, 1, nil)
  end
  Duel.Hint(HINT_OPSELECTED, 1 - tp, e:GetDescription())
  Duel.SetOperationInfo(0, CATEGORY_SUMMON, nil, 1, tp, LOCATION_HAND)
end

function s.summon_operation(e, tp, eg, ep, ev, re, r, rp)
  Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SUMMON)
  local tc = Duel.SelectMatchingCard(tp, s.summon_filter, tp, LOCATION_HAND, 0, 1, 1, nil):GetFirst()
  if tc then
    Duel.Summon(tp, tc, true, nil, 1)
  end
end

function s.destruction_condition(e)
  return e:GetHandler():IsPreviousLocation(LOCATION_SZONE)
end

function s.destruction_target(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
  if chkc then
    return chkc:IsOnField()
  end
  if chk == 0 then
    return Duel.IsExistingTarget(Card.IsSpellTrap, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, nil)
  end
  Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
  local g = nil
  if e:GetHandler():GetFlagEffect(id) ~= 0 then
    g = Duel.SelectTarget(tp, aux.TRUE, tp, LOCATION_ONFIELD, 0, 1, 1, nil)
  else
    g = Duel.SelectTarget(tp, aux.TRUE, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, 1, nil)
  end
  Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, 1, 0, 0)
end

function s.destruction_operation(e, tp, eg, ep, ev, re, r, rp)
  local tc = Duel.GetFirstTarget()
  if tc:IsRelateToEffect(e) then
    Duel.Destroy(tc, REASON_EFFECT)
  end
end
