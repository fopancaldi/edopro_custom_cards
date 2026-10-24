-- Proto-Cyber Dragon

local s, id = GetID()

function s.initial_effect(c)
  -- Name
  local e1 = Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetCode(EFFECT_CHANGE_CODE)
  e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
  e1:SetRange(LOCATION_MZONE)
  e1:SetValue(CARD_CYBER_DRAGON)
  c:RegisterEffect(e1)

  -- Summon and search
  local e2 = Effect.CreateEffect(c)
  e2:SetCategory(CATEGORY_SPECIAL_SUMMON + CATEGORY_TOHAND + CATEGORY_SEARCH)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetRange(LOCATION_MZONE)
  e2:SetCountLimit(1, id)
  e2:SetCost(Cost.SelfTribute)
  e2:SetTarget(s.summon_target)
  e2:SetOperation(s.summon_search_operation)
  c:RegisterEffect(e2)

  -- Recover
  local e3 = Effect.CreateEffect(c)
  e3:SetCategory(CATEGORY_TOHAND)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetRange(LOCATION_GRAVE)
  e3:SetCode(EVENT_TO_GRAVE)
  e3:SetCost(Cost.SelfBanish)
  e3:SetCountLimit(1, id)
  e3:SetTarget(s.recover_target)
  e3:SetOperation(s.recover_operation)
  c:RegisterEffect(e3)
end

s.listed_names = { CARD_CYBER_DRAGON }

function s.summon_filter(c, e, tp)
  return c:IsCode(CARD_CYBER_DRAGON) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.summon_target(e, tp, _, _, _, _, _, _, chk)
  local ft = Duel.GetLocationCount(tp, LOCATION_MZONE)
  if e:GetHandler():GetSequence() < 5 then ft = ft + 1 end
  if chk == 0 then
    return ft > 0 and Duel.IsExistingMatchingCard(s.summon_filter, tp, LOCATION_DECK, 0, 1, nil,
      e, tp)
  end
  Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_DECK)
  Duel.SetPossibleOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
end

function s.search_filter(c)
  return c:IsSetCard(SET_CYBER_DRAGON) and c:IsMonster() and c:IsAbleToHand()
end

function s.summon_search_operation(e, tp, eg, ep, ev, re, r, rp)
  if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end
  Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
  local mg = Duel.GetFirstMatchingCard(s.summon_filter, tp, LOCATION_DECK, 0, nil, e, tp)
  local sg = Duel.SpecialSummon(mg, 0, tp, tp, false, false, POS_FACEUP)
  if sg then
    if Duel.IsExistingMatchingCard(s.search_filter, tp, LOCATION_DECK, 0, 1, nil) and
        Duel.SelectYesNo(tp, aux.Stringid(id, 0)) then
      Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
      local sg2 = Duel.SelectMatchingCard(tp, s.search_filter, tp, LOCATION_DECK, 0, 1, 1, nil)
      if #sg2 == 0 then return end
      Duel.BreakEffect()
      Duel.SendtoHand(sg2, tp, REASON_EFFECT)
      Duel.ConfirmCards(1 - tp, sg2)
    end
  end
end

function s.recover_filter(c)
  return c:IsCode(CARD_CYBER_DRAGON) and c:IsAbleToHand()
end

function s.recover_target(e, tp, _, _, _, _, _, _, chk)
  if chk == 0 then
    return Duel.IsExistingMatchingCard(s.recover_filter, tp, LOCATION_GRAVE, 0, 1,
      e:GetHandler())
  end
  Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_GRAVE)
end

function s.recover_operation(e, tp, _, _, _, _, _, _)
  Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
  local g = Duel.SelectMatchingCard(tp, aux.NecroValleyFilter(s.recover_filter), tp, LOCATION_GRAVE, 0, 1, 1,
    e:GetHandler())
  if #g > 0 then
    Duel.SendtoHand(g, nil, REASON_EFFECT)
    Duel.ConfirmCards(1 - tp, g)
  end
end
