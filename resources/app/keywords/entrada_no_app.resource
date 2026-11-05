*** Settings ***
Documentation     Keywords de autenticação no app.
...               O destino da execução (local ou BrowserStack) é lido da variável de
...               ambiente EXECUCAO. No local o comportamento é o original (Hide Keyboard
...               e adb); no BrowserStack usa alternativas que passam pelo Appium.
Resource          ../screens/login_tela.resource
Resource          ../screens/home_tela.resource
Resource          ../../../resources/shared/variables/common_variables.resource
Library           OperatingSystem
Library           String
Library           AppiumLibrary

*** Keywords ***
# ---------- Auxiliares de destino ----------
Executando no BrowserStack
    [Documentation]    True quando EXECUCAO=browserstack. É o único lugar deste resource
    ...    que decide o destino da execução.
    ${bs}=    Evaluate    os.environ.get('EXECUCAO', 'local').lower() == 'browserstack'    modules=os
    RETURN    ${bs}

Esconder teclado
    [Documentation]    Local: Hide Keyboard como sempre. BrowserStack: o driver da nuvem não
    ...    aceita mobile: hideKeyboard nem mobile: pressKey. Fecha o teclado com o keycode
    ...    Voltar direto pelo driver (sem performEditorAction, que digitava "/done/" no campo).
    ${bs}=    Executando no BrowserStack
    IF    ${bs}
        ${lib}=       Get Library Instance    AppiumLibrary
        ${driver}=    Call Method             ${lib}    _current_application
        ${aberto}=    Evaluate                $driver.is_keyboard_shown()
        IF    ${aberto}
            Evaluate    $driver.press_keycode(4)
        END
    ELSE
        Hide Keyboard
    END
    

# ---------- Login ----------
Clicar em Acessar Conta
    [Documentation]    Clica no botão "Acessar Conta" na tela de login.
    Wait Until Element Is Visible    ${LOGIN_BTN_ACESSAR_CONTA}    10s
    Click Element                    ${LOGIN_BTN_ACESSAR_CONTA}

Registrar rótulos de autenticação na tela atual
    [Documentation]    Registra apenas rótulos relacionados à autenticação antes de inserir credenciais.
    ${fonte}=    Get Source
    ${rotulos}=    Evaluate    re.findall(r'(?:content-desc|text)="([^"]*(?:conta|login|entrar|criar)[^"]*)"', $fonte, re.I)    modules=re
    Log To Console    \nRótulos da tela de autenticação: ${rotulos}

Preencher campos de Email
    [Documentation]    Preenche o usuário email
    [Arguments]                      ${EMAIL_WILY}
    Wait Until Element Is Visible    ${LOGIN_INPUT_USERNAME}    10s
    Input Text                       ${LOGIN_INPUT_USERNAME}    ${EMAIL_WILY}
    Esconder teclado
    Click Element                    ${LOGIN_BTN_AVANCAR}

Preencher campos de senha
    [Documentation]    Local: digita caractere a caractere via adb (como era). BrowserStack:
    ...    envia as teclas por ações W3C (ActionChains), gerando eventos reais de teclado.
    ...    Isso dispara o onChangeText do React Native, que o Input Password não dispara.
    [Arguments]                      ${SENHA_WILY}
    Wait Until Element Is Visible    ${LOGIN_INPUT_PASSWORD}    10s
    Click Element                    ${LOGIN_INPUT_PASSWORD}
    ${bs}=    Executando no BrowserStack
    IF    ${bs}
        ${lib}=       Get Library Instance    AppiumLibrary
        ${driver}=    Call Method             ${lib}    _current_application
        Evaluate
        ...    selenium.webdriver.common.action_chains.ActionChains($driver).send_keys($SENHA_WILY).perform()
        ...    modules=selenium.webdriver.common.action_chains
    ELSE
        @{caracteres}=    Split String To Characters    ${SENHA_WILY}
        FOR    ${letra}    IN    @{caracteres}
            Run      adb shell input text "${letra}"
            Sleep    0.05s
        END
    END
    Esconder teclado

Clicar em Entrar
    [Documentation]    Clica no botão "Entrar" na tela de login.
    Wait Until Element Is Visible    ${LOGIN_BTN_ENTRAR}    10s
    Click Element                    ${LOGIN_BTN_ENTRAR}

Registrar estado da tela após enviar login
    [Documentation]    Registra apenas indicadores de estado, sem expor o XML nem os dados digitados.
    ${nivel_log}=    Set Log Level    WARN
    TRY
        ${fonte}=    Get Source
        ${campo_senha}=    Evaluate    bool(re.search(r'login-password-input', $fonte, re.I))    modules=re
        ${home}=    Evaluate    bool(re.search(r'resource-id="menu"', $fonte, re.I))    modules=re
        ${carregando}=    Evaluate    bool(re.search(r'Carregando suas informações|Loading', $fonte, re.I))    modules=re
        ${erro_credenciais}=    Evaluate    bool(re.search(r'(usu[aá]rio|senha).{0,40}(inv[aá]lid|incorret)|(inv[aá]lid|incorret).{0,40}(usu[aá]rio|senha)|credential|unauthori[sz]ed', $fonte, re.I))    modules=re
        ${erro_rede}=    Evaluate    bool(re.search(r'network|rede|conex[aã]o|connection|internet|timeout|servidor|server', $fonte, re.I))    modules=re
        ${erro_generico}=    Evaluate    bool(re.search(r'erro|error|falha|failed', $fonte, re.I))    modules=re
    FINALLY
        Set Log Level    ${nivel_log}
    END
    Log To Console    \nLogin UI flags after submit: password_field=${campo_senha}, home_menu=${home}, loading=${carregando}, credential_error=${erro_credenciais}, network_error=${erro_rede}, generic_error=${erro_generico}

Verificar se o login foi realizado com sucesso
    [Documentation]    Confirma a Home e identifica estados de falha conhecidos após o login.
    ${home_visivel}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${HOME_BTN_MENU}    ${DEFAULT_TIMEOUT}s
    IF    ${home_visivel}
        RETURN
    END

    ${carregando}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOGIN_TXT_CARREGANDO}    1s
    IF    ${carregando}
        Fail    Login enviado, mas o app permaneceu em "Carregando suas informações..." por ${DEFAULT_TIMEOUT}s.
    END

    ${usuario_invalido}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOGIN_TXT_USUARIO_INVALIDO}    1s
    IF    ${usuario_invalido}
        Fail    Login recusado: o app exibiu "Usuário inválida".
    END

    ${nao_autorizado}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOGIN_TXT_USUARIO_NAO_AUTORIZADO}    1s
    IF    ${nao_autorizado}
        Fail    Login recusado: o app exibiu "Não autorizado".
    END

    ${modal_erro}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${BOTAO_TENTAR_NOVAMENTE}    1s
    IF    ${modal_erro}
        Fail    Login não chegou à Home e o app exibiu um modal com opção de tentar novamente.
    END

    Fail    Login não chegou à Home em ${DEFAULT_TIMEOUT}s e nenhum erro conhecido foi identificado.

Realizar login
    [Documentation]    Realiza o fluxo completo de login no aplicativo.
    [Arguments]    ${EMAIL_WILY}    ${SENHA_WILY}
    Clicar em Acessar Conta
    Preencher campos de Email    ${EMAIL_WILY}
    Preencher campos de senha    ${SENHA_WILY}
    Clicar em Entrar
    Verificar se o login foi realizado com sucesso