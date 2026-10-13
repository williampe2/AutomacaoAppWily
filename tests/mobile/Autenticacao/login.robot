*** Settings ***
Documentation    Validar o fluxo de login no app 
Variables        ../../../config/secrets.yaml
Variables        ../../../resources/data/perfis_usuarios.yaml 
Resource         ../../../resources/shared/base.resource
Resource         ../../../resources/app/keywords/entrada_no_app.resource
Resource         ../../../resources/app/keywords/quiz.resource
suite Setup       Abrir Aplicativo Wily no Emulador
suite Teardown    Fechar Aplicativo Wily

*** Test Cases ***
Cenario: Login com sucesso 
    [Tags]    mobile    smoke    #  a tags é O smoke é um teste rápido que valida se o app está funcionando, sem entrar em detalhes de funcionalidades.
    ${email_yaml}     Set Variable     ${usuarios}[wily_DA][usuario_app] 
    ${senha_yaml}     Set Variable     ${usuarios}[wily_DA][senha_app]
    Clicar em Acessar Conta
    Preencher campos de Email          ${email_yaml}
    preencher campos de senha          ${senha_yaml}          
    Clicar em Entrar
    ${existe_quiz}     Run keyword And Return Status        Wait until Element Is Visible    ${QUIZ_BTN_DEIXAR_DEPOIS_QUIZ}    5s
    IF  ${existe_quiz}
        Clicar em Deixar para depois
    END
    Verificar se o login foi realizado com sucesso
    Sleep  5s
Entra no app sem o login
    Verificar se o login foi realizado com sucesso

