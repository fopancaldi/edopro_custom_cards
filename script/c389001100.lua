--Magical Musket - Steady Hands
local s, id = GetID()

function s.initial_effect(c)
  --Activate 1 of 2 effects
  local e1 = Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetCode(EVENT_FREE_CHAIN)
  e1:SetProperty(EFFECT_FLAG_CARD_TARGET + EFFECT_FLAG_DAMAGE_STEP)
  e1:SetCountLimit(1, id, EFFECT_COUNT_CODE_OATH)
  e1:SetHintTiming(TIMING_DAMAGE_STEP)
  e1:SetCondition(aux.StatChangeDamageStepCondition)
  e1:SetTarget(s.target)
  e1:SetOperation(s.activate)
  c:RegisterEffect(e1)
  aux.GlobalCheck(s, function()
    local ge1 = Effect.CreateEffect(c)
    ge1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    ge1:SetCode(EVENT_ATTACK_ANNOUNCE)
    ge1:SetOperation(s.global_check_operation)
    Duel.RegisterEffect(ge1, 0)
  end)
end

s.listed_series = { SET_MAGICAL_MUSKET }

function s.global_check_operation(_, _, eg, _, _, _, _, _)
  local tc = eg:GetFirst()
  if tc:GetFlagEffect(id) == 0 and Duel.GetAttackTarget() == nil then
    tc:RegisterFlagEffect(id, RESETS_STANDARD_PHASE_END, 0, 1)
  end
end

function s.target_filter(c)
  return c:IsFaceup()
    and c:IsSetCard(SET_MAGICAL_MUSKET)
    and c:HasLevel()
    and c:GetLevel() <= 4
    and c:GetFlagEffect(id) == 0
end

function s.search_filter(c)
  return c:IsCode(id) and c:IsAbleToHand()
end

function s.target(e, tp, _, _, _, _, _, _, chk, chkc)
  if chkc then
    return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.target_filter(chkc)
  end
  if chk == 0 then
    return Duel.IsExistingTarget(s.target_filter, tp, LOCATION_MZONE, 0, 1, nil)
  end
  Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_FACEUP)
  local g = Duel.SelectTarget(tp, s.target_filter, tp, LOCATION_MZONE, 0, 1, 1, nil)
  Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_EFFECT)
  local op = nil
  if
    not g:GetFirst():IsHasEffect(EFFECT_CANNOT_CHANGE_POS_E)
    and Duel.IsExistingMatchingCard(s.search_filter, tp, LOCATION_DECK, 0, 1, nil)
  then
    op = Duel.SelectOption(tp, aux.Stringid(id, 0), aux.Stringid(id, 1))
  else
    op = Duel.SelectOption(tp, aux.Stringid(id, 0))
  end
  if op == 0 then
    local e1 = Effect.CreateEffect(e:GetHandler())
    e:SetCategory(CATEGORY_ATKCHANGE)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
    e1:SetReset(RESETS_STANDARD_PHASE_END)
    g:GetFirst():RegisterEffect(e1)
  else
    e:SetCategory(CATEGORY_TOHAND + CATEGORY_POSITION + CATEGORY_SEARCH)
  end
  e:SetLabel(op)
end

function s.activate(e, tp, _, _, _, _, _, _)
  local c = e:GetHandler()
  local tc = Duel.GetFirstTarget()
  if tc:IsRelateToEffect(e) and tc:IsFaceup() then
    if e:GetLabel() == 0 then
      local e1 = Effect.CreateEffect(e:GetHandler())
      e1:SetDescription(3207)
      e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
      e1:SetType(EFFECT_TYPE_SINGLE)
      e1:SetCode(EFFECT_UPDATE_ATTACK)
      e1:SetValue(2500)
      e1:SetReset(RESETS_STANDARD_PHASE_END)
      tc:RegisterEffect(e1)
    else
      Duel.ChangePosition(tc, POS_FACEUP_DEFENSE, 0, POS_FACEUP_ATTACK, 0)
      Duel.BreakEffect()
      local tc = Duel.GetFirstMatchingCard(s.search_filter, tp, LOCATION_DECK, 0, nil)
      if tc then
        Duel.SendtoHand(tc, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, tc)
      end
    end
  end
end
