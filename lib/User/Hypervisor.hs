module User.Hypervisor where

import XMonad

import User.Terminal

-- Minikube

startMinikube :: X ()
startMinikube = launchTUI "minikube start" Nothing Nothing

stopMinikube :: X ()
stopMinikube = launchTUI "minikube stop" Nothing Nothing

minikubeUseMinikube :: X ()
minikubeUseMinikube = launchTUI "kubectl config use-context minikube" Nothing Nothing
