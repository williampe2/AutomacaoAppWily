*** Settings ***
Documentation    fluxos do quiz do app.
Resource        ../screens/quiz_tela.resource
Resource    ../../../resources/shared/variables/common_variables.resource

*** Keywords ***
Clicar em Deixar para depois
    [Documentation]    clica no botão "Deixar para depois" na tela de quiz.
    wait until Element Is Visible    ${QUIZ_BTN_DEIXAR_DEPOIS_QUIZ}    10s
    Click Element                    ${QUIZ_BTN_DEIXAR_DEPOIS_QUIZ}
