--Dreiath III, the True Dracocavalry General
local s, id = GetID()
Duel.LoadScript("fopancaldi_aux.lua")

function s.initial_effect(c)
  --Summon with s/t
  local e1 = Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
  e1:SetCode(EFFECT_ADD_EXTRA_TRIBUTE)
  e1:SetTargetRange(LOCATION_SZONE, 0)
  e1:SetTarget(aux.TargetBoolFunction(Card.IsType, TYPE_CONTINUOUS))
  e1:SetValue(POS_FACEUP)
  c:RegisterEffect(e1)
  --Opponent cannot target other cards you control with card effects
  local e2 = Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD)
  e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
  e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE + EFFECT_FLAG_SET_AVAILABLE)
  e2:SetRange(LOCATION_MZONE)
  e2:SetTargetRange(LOCATION_ONFIELD, 0)
  e2:SetTarget(s.protection_target)
  c:RegisterEffect(e2)
  --Search
  local e3 = Effect.CreateEffect(c)
  e3:SetCategory(CATEGORY_DESTROY + CATEGORY_TOHAND + CATEGORY_SEARCH)
  e3:SetType(EFFECT_TYPE_QUICK_O)
  e3:SetCode(EVENT_CHAINING)
  e3:SetRange(LOCATION_MZONE)
  e3:SetCountLimit(1)
  e3:SetCondition(s.search_condition)
  e3:SetTarget(s.search_target)
  e3:SetOperation(s.search_operation)
  c:RegisterEffect(e3)
end

s.listed_series = { SET_TRUE_DRACO_KING }
s.listed_cards = { CARD_DRAGONIC_DRAGRAM }

function s.protection_target(e, c)
  return c ~= e:GetHandler()
end

function s.search_condition(e, tp, _, _, _, _, _, rp)
  return e:GetHandler():IsTributeSummoned() and rp ~= tp
end

function s.search_filter(c, tp)
  return c:IsCode(CARD_DRAGONIC_DIAGRAM) and (c:IsAbleToHand() or (c:GetActivateEffect():IsActivatable(tp, true, true)))
end

function s.search_target(_, tp, _, _, _, _, _, _, chk)
  if chk == 0 then
    return Duel.IsExistingMatchingCard(s.search_filter, tp, LOCATION_DECK, 0, 1, nil, tp)
  end
  Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
end

function s.destructable_filter(c)
  return c:IsDestructable()
end

function s.search_operation(e, tp, eg, ep, ev, re, r, rp)
  local tc = Duel.GetFirstMatchingCard(s.search_filter, tp, LOCATION_DECK, 0, nil)
  aux.ToHandOrElse(tc, tp, function(_)
    return tc:GetActivateEffect():IsActivatable(tp, true, true)
  end, function(_)
    Duel.ActivateFieldSpell(tc, e, tp, eg, ep, ev, re, r, rp)
  end, aux.Stringid(id, 0))

  if not tc:IsLocation(LOCATION_DECK) then
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
    local sg1 = Duel.SelectMatchingCard(tp, s.destructable_filter, tp, LOCATION_ONFIELD, 0, 1, 1, nil)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
    local sg2 = Duel.SelectMatchingCard(tp, s.destructable_filter, tp, 0, LOCATION_ONFIELD, 1, 1, nil)
    sg1:Merge(sg2)
    if #sg1 > 0 then
      Duel.Destroy(sg1, REASON_EFFECT)
    end
  end
end
