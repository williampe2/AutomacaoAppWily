*** Settings ***
Documentation    Cenário básico para validar a comunicação entre Robot, Appium e Emulador.
Resource         ../../resources/shared/base.resource        #Aqui temso keywords compartilhadas entre web e app.robot -d results tests/e2e/vistorias/validacao_ambiente.robot

# Test Setup é o que roda ANTES de cada Test Case
Test Setup       Abrir Aplicativo Wily no Emulador

# Test Teardown é o que roda DEPOIS de cada Test Case (mesmo se o teste falhar)
Test Teardown    Fechar Aplicativo Wily

*** Test Cases ***
Cenario 1: Validar se o emulador abre o app do Wily corretamente
    [Documentation]    Teste simples para garantir que a arquitetura está funcionando.    # o documentation é o que aparece no relatório do Robot, não no console do terminal
    Log To Console     \n>>> Sucesso! O Appium conseguiu se conectar ao Emulador! <<<    # informações que aparecem no console do terminal, não no log do Robot
    
    # somente para fins de demonstração, para que o teste não feche imediatamente
    Sleep    5s
