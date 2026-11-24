module User.Utilities where

import XMonad

import User.Spawn (safeSpawn)

-- Dictionaries

dictLookup :: X ()
dictLookup = safeSpawn "dmenu-dict"

-- Thesauri

thesaurusLookup :: X ()
thesaurusLookup = safeSpawn "dmenu-thesaurus"

-- Calculators

dmenuCalculator :: X ()
dmenuCalculator = safeSpawn "dmenu-calc"

openQalculate :: X ()
openQalculate = safeSpawn "qalculate-gtk"

-- Screenshots

dmenuShot :: X ()
dmenuShot = safeSpawn "dmenu_shot"
