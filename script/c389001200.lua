-- Kashtira Fenrir

local s, id = GetID()

function s.initial_effect(c)
  -- Summon if you control no monsters
  local e1 = Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
  e1:SetCode(EFFECT_SPSUMMON_PROC)
  e1:SetRange(LOCATION_HAND)
  e1:SetCondition(s.summon_condition)
  c:RegisterEffect(e1)
  -- Search
  local e2 = Effect.CreateEffect(c)
  e2:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetRange(LOCATION_MZONE)
  e2:SetCountLimit(1, id)
  e2:SetTarget(s.search_target)
  e2:SetOperation(s.search_operation)
  c:RegisterEffect(e2)
  -- Banish
  local e3 = Effect.CreateEffect(c)
  e3:SetCategory(CATEGORY_REMOVE)
  e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
  e3:SetCode(EVENT_ATTACK_ANNOUNCE)
  e3:SetRange(LOCATION_MZONE)
  e3:SetCountLimit(1, { id, 1 })
  e3:SetTarget(s.banish_target)
  e3:SetOperation(s.banish_operation)
  c:RegisterEffect(e3)
  local e4 = e3:Clone()
  e4:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
  e4:SetProperty(EFFECT_FLAG_DELAY)
  e4:SetCode(EVENT_CHAINING)
  e4:SetCondition(s.banish_condition)
  c:RegisterEffect(e4)
end

s.listed_series = { SET_KASHTIRA }

function s.summon_condition(e, c)
  if c == nil then return true end
  local tp = e:GetHandlerPlayer()
  return Duel.GetFieldGroupCount(tp, LOCATION_MZONE, 0) == 0 and Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
end

function s.search_filter(c)
  return c:IsSetCard(SET_KASHTIRA) and c:IsMonster() and not c:IsCode(id) and c:IsAbleToHand()
end

function s.search_target(_, tp, _, _, _, _, _, _, chk)
  if chk == 0 then return Duel.IsExistingMatchingCard(s.search_filter, tp, LOCATION_DECK, 0, 1, nil) end
  Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
end

function s.search_operation(_, tp, _, _, _, _, _, _)
  Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
  local g = Duel.SelectMatchingCard(tp, s.search_filter, tp, LOCATION_DECK, 0, 1, 1, nil)
  if #g > 0 then
    Duel.SendtoHand(g, nil, REASON_EFFECT)
    Duel.ConfirmCards(1 - tp, g)
  end
end

function s.banish_target(_, tp, _, _, _, _, _, _, chk)
  if chk == 0 then return Duel.GetFieldGroupCount(tp, 0, LOCATION_DECK) > 0 and Duel.IsPlayerCanRemove(tp) end
  Duel.SetOperationInfo(0, CATEGORY_REMOVE, nil, 1, 1 - tp, LOCATION_DECK)
end

function s.banish_operation(_, tp, _, _, _, _, _, _)
  local ct = math.min(5, Duel.GetFieldGroupCount(tp, 0, LOCATION_DECK))
  if ct == 0 then return end
  local ac = Duel.AnnounceNumberRange(tp, 1, ct)
  Duel.ConfirmDecktop(1 - tp, ac)
  local g = Duel.GetDecktopGroup(1 - tp, ac)
  Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_REMOVE)
  local sg = g:FilterSelect(tp, Card.IsAbleToRemove, 1, 1, nil, tp, POS_FACEDOWN)
  if #sg > 0 then
    Duel.DisableShuffleCheck(true)
    Duel.Remove(sg, POS_FACEDOWN, REASON_EFFECT)
  end
end

function s.banish_condition(_, tp, _, ep, _, re, _, _)
  return ep == 1 - tp and re:IsMonsterEffect()
end
