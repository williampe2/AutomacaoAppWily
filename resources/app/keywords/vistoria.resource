*** Settings ***
Documentation     Keywords do fluxo de vistoria no app: iniciar turno, aceitar oferta,
...               iniciar/enviar fotos, abandonar e finalizar.
Resource          ../screens/vistoria_tela.resource
Resource          ../../shared/variables/common_variables.resource
Library           BuiltIn
Library           OperatingSystem

*** Keywords ***
# ---------- Auxiliares anti-stale ----------
Aparece na tela
    [Documentation]    Retorna True/False se o elemento fica visível no tempo informado.
    ...    Se a tela for redesenhada no meio da checagem (StaleElementReference),
    ...    refaz a busca em vez de devolver False por engano.
    [Arguments]    ${locator}    ${timeout}=2s
    FOR    ${tentativa}    IN RANGE    3
        ${status}    ${mensagem}=    Run Keyword And Ignore Error
        ...    AppiumLibrary.Wait Until Element Is Visible    ${locator}    ${timeout}
        IF    $status == 'PASS'    RETURN    ${True}
        ${stale}=    Evaluate    'StaleElementReference' in $mensagem
        IF    not ${stale}
            Log    ${mensagem}    DEBUG
            RETURN    ${False}
        END
    END
    RETURN    ${False}

Aguardar elemento visível
    [Documentation]    Espera o elemento ficar visível, refazendo a busca a cada tentativa.
    [Arguments]    ${locator}    ${timeout}=${DEFAULT_TIMEOUT}s
    BuiltIn.Wait Until Keyword Succeeds    ${timeout}    1s
    ...    AppiumLibrary.Wait Until Element Is Visible    ${locator}    3s

Conceder acesso à câmera se solicitado
    [Documentation]    Toca no botão de permissão da tela explicativa e aceita o diálogo Android, se exibido.
    ${aviso}=    Run Keyword And Return Status
    ...    AppiumLibrary.Wait Until Element Is Visible    ${VISTORIA_TELA_ACESSO_CAMERA}    2s
    IF    not ${aviso}    RETURN
    Clicar quando visível    ${VISTORIA_BTN_CONCEDER_CAMERA}    8s
    ${dialogo}=    Run Keyword And Return Status
    ...    AppiumLibrary.Wait Until Element Is Visible    ${VISTORIA_DIALOGO_PERMISSAO_CAMERA_ALLOW}    5s
    IF    ${dialogo}
        AppiumLibrary.Click Element    ${VISTORIA_DIALOGO_PERMISSAO_CAMERA_ALLOW}
    END
    AppiumLibrary.Wait Until Page Does Not Contain Element    ${VISTORIA_TELA_ACESSO_CAMERA}    10s

Clicar quando visível
    [Documentation]    Espera o elemento ficar visível e clica, refazendo a busca a cada
    ...    tentativa. Tolera o redesenho da tela (StaleElementReferenceException).
    [Arguments]    ${locator}    ${timeout}=${DEFAULT_TIMEOUT}s
    BuiltIn.Wait Until Keyword Succeeds    ${timeout}    1s    Tentar clicar    ${locator}

Tentar clicar
    [Documentation]    Uma tentativa de achar o elemento e clicar nele.
    [Arguments]    ${locator}
    AppiumLibrary.Wait Until Element Is Visible    ${locator}    3s
    AppiumLibrary.Click Element                    ${locator}

Digitar quando visível
    [Documentation]    Espera o campo ficar visível e digita, refazendo a busca a cada tentativa.
    [Arguments]    ${locator}    ${texto}    ${timeout}=${DEFAULT_TIMEOUT}s
    BuiltIn.Wait Until Keyword Succeeds    ${timeout}    1s    Tentar digitar    ${locator}    ${texto}

Tentar digitar
    [Documentation]    Uma tentativa de achar o campo e digitar nele.
    [Arguments]    ${locator}    ${texto}
    AppiumLibrary.Wait Until Element Is Visible    ${locator}    3s
    AppiumLibrary.Input Text                       ${locator}    ${texto}

Deslizar para cima
    [Documentation]    Swipe vertical para cima com coordenadas inteiras. Os percentuais
    ...    são da altura da tela.
    [Arguments]    ${inicio_pct}=0.75    ${fim_pct}=0.35    ${duracao}=600ms
    ${largura}=    AppiumLibrary.Get Window Width
    ${altura}=     AppiumLibrary.Get Window Height
    ${x}=          Evaluate    int(int($largura) / 2)
    ${y_i}=        Evaluate    int(int($altura) * float($inicio_pct))
    ${y_f}=        Evaluate    int(int($altura) * float($fim_pct))
    AppiumLibrary.Swipe    start_x=${x}    start_y=${y_i}    end_x=${x}    end_y=${y_f}    duration=${duracao}

# ---------- Início do turno ----------
Iniciar
    [Documentation]    Inicia o turno tocando em "Iniciar" na Home. Se já houver um
    ...    atendimento em andamento ("Caminhe até o local"), não faz nada.
    ${em_atendimento}=    Aparece na tela    ${VISTORIA_ETAPA_CAMINHE}    2s
    IF    ${em_atendimento}
        RETURN
    END
    Clicar quando visível    ${VISTORIA_BTN_INICIAR}

Identificar estado inicial
    [Documentation]    Após Iniciar, identifica a tela exibida e retorna o cenário:
    ...    aviso_sem_vistorias | com_vistorias | sem_ordens.
    ${aviso}=    Aparece na tela    ${VISTORIA_BTN_FICAR_ONLINE_MESMO_ASSIM}    10s
    IF    ${aviso}
        RETURN    aviso_sem_vistorias
    END
    ${oferta}=    Oferta visível    10s
    IF    ${oferta}
        RETURN    com_vistorias
    END
    ${sem_ordens}=    Aparece na tela    ${VISTORIA_TXT_SEM_ORDENS}    5s
    IF    ${sem_ordens}
        RETURN    sem_ordens
    END
    Fail    Tela inesperada após Iniciar.

Identificar estado online
    [Documentation]    Após ficar online, retorna com_vistorias ou sem_ordens.
    ${oferta}=    Oferta visível    15s
    IF    ${oferta}
        RETURN    com_vistorias
    END
    ${sem_ordens}=    Aparece na tela    ${VISTORIA_TXT_SEM_ORDENS}    5s
    IF    ${sem_ordens}
        RETURN    sem_ordens
    END
    Fail    Tela inesperada após ficar online.

Oferta visível
    [Documentation]    Verifica se há uma oferta de vistoria na tela.
    [Arguments]    ${timeout}=5s
    ${visivel}=    Aparece na tela    ${VISTORIA_OFERTA_TXT_ACEITAR}    ${timeout}
    RETURN    ${visivel}

Ficar online
    [Documentation]    Fica online mesmo sem vistorias por perto.
    Clicar quando visível    ${VISTORIA_BTN_FICAR_ONLINE_MESMO_ASSIM}

Fechar
    [Documentation]    Fecha o aviso de "sem ordens de serviço".
    Clicar quando visível    ${VISTORIA_BTN_FECHAR}

# ---------- Oferta ----------
Aceitar oferta
    [Documentation]    Arrasta o slider "Aceitar" da oferta. Re-tenta enquanto a oferta
    ...    permanecer na tela, pois ela expira e é substituída por outra. Se já houver
    ...    um atendimento em andamento, não faz nada.
    ${em_atendimento}=    Aparece na tela    ${VISTORIA_ETAPA_CAMINHE}    2s
    IF    ${em_atendimento}
        RETURN
    END
    Aguardar elemento visível    ${VISTORIA_OFERTA_TXT_ACEITAR}
    BuiltIn.Wait Until Keyword Succeeds    120s    3s    Arrastar slider de aceite
    Aguardar elemento visível    ${VISTORIA_ETAPA_CAMINHE}

Arrastar slider de aceite
    [Documentation]    Arrasta a alça do slider "Aceitar" até o fim da trilha, usando o
    ...    bounds real do label (que cobre a trilha inteira). Falha (e re-tenta)
    ...    enquanto a etapa "Caminhe até o local" não aparecer.
    ${loc}=       AppiumLibrary.Get Element Location    ${VISTORIA_OFERTA_TXT_ACEITAR}
    ${tam}=       AppiumLibrary.Get Element Size        ${VISTORIA_OFERTA_TXT_ACEITAR}
    ${y}=         Evaluate    int($loc['y'] + $tam['height'] / 2)
    ${inicio}=    Evaluate    int($loc['x'] + 49)
    ${fim}=       Evaluate    int($loc['x'] + $tam['width'] - 25)
    &{args}=      Create Dictionary    startX=${inicio}    startY=${y}    endX=${fim}    endY=${y}    speed=800
    AppiumLibrary.Execute Script    mobile: dragGesture    &{args}
    Aguardar elemento visível    ${VISTORIA_ETAPA_CAMINHE}    5s

# ---------- Vistoria ----------
Rolar até Iniciar vistoria
    [Documentation]    Rola a tela do atendimento até o botão "Iniciar vistoria" ficar visível.
    Aguardar elemento visível    ${VISTORIA_ETAPA_CAMINHE}
    FOR    ${tentativa}    IN RANGE    10
        ${visivel}=    Aparece na tela    ${VISTORIA_BTN_INICIAR_VISTORIA}    2s
        Exit For Loop If    ${visivel}
        Deslizar para cima    0.8    0.3    700ms
    END
    Aguardar elemento visível    ${VISTORIA_BTN_INICIAR_VISTORIA}

Iniciar vistoria
    [Documentation]    Inicia a vistoria e rola até o botão "Enviar fotos" ficar visível.
    Clicar quando visível        ${VISTORIA_BTN_INICIAR_VISTORIA}
    FOR    ${tentativa}    IN RANGE    6
        ${visivel}=    Aparece na tela    ${VISTORIA_BTN_ENVIAR_FOTOS}    2s
        Exit For Loop If    ${visivel}
        Deslizar para cima    0.8    0.3    700ms
    END
    Aguardar elemento visível    ${VISTORIA_BTN_ENVIAR_FOTOS}

Enviar fotos
    [Documentation]    Abre a tela de envio de mídias da vistoria.
    Clicar quando visível        ${VISTORIA_BTN_ENVIAR_FOTOS}
    Aguardar elemento visível    ${VISTORIA_TITULO_ENVIAR_VISTORIA}

Completar mídias e concluir
    [Documentation]    Captura em sequência nos slots de referência, aproximada,
    ...    centralizada e aberta, depois adiciona o vídeo.
    Injetar vídeo na câmera
    Adicionar foto    ${VISTORIA_ADD_REFERENCIA}      ${VISTORIA_FOTO_REFERENCIA}
    Adicionar foto    ${VISTORIA_ADD_APROXIMADA}      ${VISTORIA_FOTO_APROXIMADA}
    Adicionar foto    ${VISTORIA_ADD_CENTRALIZADA}    ${VISTORIA_FOTO_CENTRALIZADA}
    Adicionar foto    ${VISTORIA_ADD_ABERTA}          ${VISTORIA_FOTO_ABERTA}
    Adicionar vídeo
    Rolar tela de mídias até o fim
    Aguardar vídeo enviado
    Concluir vistoria

Rolar tela de mídias até o fim
    [Documentation]    Rola a tela de mídias até o botão "Concluir vistoria" aparecer
    ...    (fim da lista). Rola no máximo 6 vezes.
    FOR    ${i}    IN RANGE    6
        ${visivel}=    Aparece na tela    ${VISTORIA_BTN_CONCLUIR}    2s
        Exit For Loop If    ${visivel}
        Rolar tela de mídias
    END

Rolar até slot
    [Documentation]    Rola a tela de mídias até o slot vazio informado ficar visível.
    ...    Rola no máximo 6 vezes para cima.
    [Arguments]    ${slot}
    FOR    ${i}    IN RANGE    6
        ${visivel}=    Aparece na tela    ${slot}    2s
        Exit For Loop If    ${visivel}
        Rolar tela de mídias
    END
    Aguardar elemento visível    ${slot}

Rolar tela de mídias
    [Documentation]    Swipe único para cima na área de mídias.
    Deslizar para cima    0.75    0.35    600ms

Confirmar foto
    [Documentation]    Dispara a câmera e confirma a foto. Espera até ~20s pelo botão de
    ...    confirmar ou pelo erro "Erro ao tirar foto". Se der erro, toca em
    ...    "Tentar novamente" e dispara de novo (até 3 vezes).
    [Arguments]    ${foto}
    Aguardar elemento visível    ${VISTORIA_TEXTO_ZOOM_CAMERA}
    BuiltIn.Sleep    2s
    FOR    ${tentativa}    IN RANGE    3
        Disparar câmera
        ${erro}=    Aguardar confirmação ou erro da foto
        IF    not ${erro}    BREAK
        Log    Erro ao tirar foto (tentativa ${tentativa + 1}); tocando em Tentar novamente.    WARN
        AppiumLibrary.Click Element    id=error-modal-try-again
        BuiltIn.Sleep    2s
    END
    Clicar quando visível        ${VISTORIA_BTN_CONFIRMAR_FOTO}
    Aguardar elemento visível    ${foto}

Aguardar confirmação ou erro da foto
    [Documentation]    Espera até ~20s. Retorna True se apareceu o erro de foto, False se
    ...    apareceu o botão de confirmar (ou se nada apareceu).
    FOR    ${i}    IN RANGE    10
        ${confirmar}=    Aparece na tela    ${VISTORIA_BTN_CONFIRMAR_FOTO}    1s
        IF    ${confirmar}    RETURN    ${False}
        ${erro}=    Aparece na tela    id=error-modal-try-again    1s
        IF    ${erro}    RETURN    ${True}
    END
    RETURN    ${False}

Disparar câmera
    [Documentation]    Toca o obturador da câmera (foto).
    Tocar obturador

Tocar botão de gravação
    [Documentation]    Toca o obturador para iniciar ou parar a gravação. É o mesmo
    ...    botão da foto.
    Tocar obturador

Tocar obturador
    [Documentation]    Tenta achar o obturador pela geometria (ViewGroup clicável
    ...    centralizado na horizontal e no terço inferior da tela). Se não achar,
    ...    toca por coordenada.
    ${status}=    Run Keyword And Return Status    Tocar obturador pelo elemento
    IF    ${status}    RETURN
    Log    Obturador não encontrado pelo XML; usando toque por coordenada.    WARN
    Tocar obturador por coordenada

Tocar obturador pelo elemento
    [Documentation]    Percorre os ViewGroup clicáveis e clica no que fica no centro
    ...    horizontal (±10% da largura) e abaixo de 80% da altura. Falha se nenhum servir.
    ${largura}=    AppiumLibrary.Get Window Width
    ${altura}=     AppiumLibrary.Get Window Height
    @{candidatos}=    AppiumLibrary.Get Webelements    xpath=//android.view.ViewGroup[@clickable="true"]
    FOR    ${el}    IN    @{candidatos}
        ${loc}=    AppiumLibrary.Get Element Location    ${el}
        ${tam}=    AppiumLibrary.Get Element Size        ${el}
        ${cx}=    Evaluate    int($loc['x'] + $tam['width'] / 2)
        ${cy}=    Evaluate    int($loc['y'] + $tam['height'] / 2)
        ${centrado}=    Evaluate    abs($cx - int($largura) / 2) < int($largura) * 0.1
        ${embaixo}=     Evaluate    $cy > int($altura) * 0.8
        IF    ${centrado} and ${embaixo}
            AppiumLibrary.Click Element    ${el}
            RETURN
        END
    END
    Fail    Obturador não encontrado entre os elementos clicáveis.

Tocar obturador por coordenada
    [Documentation]    Fallback: toca no centro do obturador (50% da largura, 96% da altura do app).
    ${largura}=    AppiumLibrary.Get Window Width
    ${altura}=     Altura do app
    ${x}=    Evaluate    int(int($largura) * 0.5)
    ${y}=    Evaluate    int(int($altura) * 0.96)
    Tocar em coordenada    ${x}    ${y}

Adicionar foto
    [Documentation]    Abre o modal "Adicionar mídia" pelo botão da categoria, escolhe
    ...    a Câmera, tira e confirma a foto.
    [Arguments]    ${botao_adicionar}    ${foto}
    Rolar até slot    ${botao_adicionar}
    Clicar quando visível    ${botao_adicionar}
    Abrir câmera pelo modal
    Confirmar foto           ${foto}

Abrir câmera pelo modal
    [Documentation]    No modal "Adicionar mídia", toca em "Câmera" e aguarda a câmera abrir.
    ...    Se aparecer "Erro na câmera", volta e abre de novo (até 3 tentativas).
    Clicar quando visível        ${VISTORIA_BTN_CAMERA}
    Conceder acesso à câmera se solicitado
    FOR    ${tentativa}    IN RANGE    3
        ${ok}=    Aparece na tela    ${VISTORIA_TEXTO_ZOOM_CAMERA}    5s
        Exit For Loop If    ${ok}
        ${erro}=    Aparece na tela    xpath=//android.view.ViewGroup[contains(@content-desc,"Erro na câmera")]    1s
        IF    ${erro}
            Log    Erro na câmera (tentativa ${tentativa + 1}); voltando e reabrindo.    WARN
            AppiumLibrary.Press Keycode    4
            BuiltIn.Sleep    3s
            ${modal}=    Aparece na tela    ${VISTORIA_BTN_CAMERA}    3s
            IF    ${modal}
                AppiumLibrary.Click Element    ${VISTORIA_BTN_CAMERA}
                Conceder acesso à câmera se solicitado
            END
        END
    END
    Aguardar elemento visível    ${VISTORIA_TEXTO_ZOOM_CAMERA}

Injetar vídeo na câmera
    [Documentation]    Injeta o vídeo enviado pelo CI (BS_VIDEO_URL) como feed da câmera.
    ...    Só atua no BrowserStack (EXECUCAO=browserstack); no local, não faz nada.
    ...    Precisa rodar ANTES de acionar a câmera, que captura o último vídeo injetado.
    IF    '%{EXECUCAO=local}' != 'browserstack'
        RETURN
    END
    ${url}=    Get Environment Variable    BS_VIDEO_URL    default=${EMPTY}
    Should Not Be Empty    ${url}
    ...    msg=BS_VIDEO_URL não definida: o upload do vídeo não rodou.
    ${script}=    Set Variable
    ...    browserstack_executor: {"action": "cameraVideoInjection", "arguments": {"videoUrl": "${url}"}}
    AppiumLibrary.Execute Script    ${script}

Adicionar vídeo
    [Documentation]    Abre o modal "Adicionar mídia" da seção Vídeos, injeta o vídeo no
    ...    feed da câmera (BrowserStack), abre a Câmera, grava ao menos 16s (o app
    ...    exige no mínimo 15s) com 2s de folga e confirma o vídeo.
    Clicar no campo de vídeo
    Abrir câmera pelo modal
    BuiltIn.Sleep    3s
    Iniciar gravação do vídeo
    ${duracao}=    Evaluate    int(${VISTORIA_VIDEO_MINIMO_SEGUNDOS}) + 2
    BuiltIn.Sleep    ${duracao}s
    Parar gravação do vídeo
    BuiltIn.Sleep    3s
    Clicar quando visível        ${VISTORIA_BTN_CONFIRMAR_FOTO}    20s
    Aguardar elemento visível    ${VISTORIA_VIDEO_TILE}

Clicar no campo de vídeo
    [Documentation]    Clica no botão add-media logo abaixo do título da seção "Videos".
    ...    O índice dos botões muda conforme as seções fora da tela são recicladas.
    FOR    ${tentativa}    IN RANGE    6
        ${visivel}=    Aparece na tela    ${VISTORIA_TITULO_VIDEO}    2s
        Exit For Loop If    ${visivel}
        Rolar tela de mídias
    END
    Aguardar elemento visível    ${VISTORIA_TITULO_VIDEO}
    ${titulo}=    AppiumLibrary.Get Element Location    ${VISTORIA_TITULO_VIDEO}
    ${tamanho_titulo}=    AppiumLibrary.Get Element Size    ${VISTORIA_TITULO_VIDEO}
    ${limite_y}=    Evaluate    int($titulo['y'] + $tamanho_titulo['height'])
    @{botoes_adicionar}=    AppiumLibrary.Get Webelements    xpath=//*[@resource-id="add-media"]
    ${botao_video}=    Set Variable    ${None}
    FOR    ${botao}    IN    @{botoes_adicionar}
        ${local}=    AppiumLibrary.Get Element Location    ${botao}
        ${y}=    Evaluate    int($local['y'])
        IF    $y > $limite_y
            ${botao_video}=    Set Variable    ${botao}
            Exit For Loop
        END
    END
    IF    $botao_video is None
        Fail    Não encontrei o campo de envio de vídeo abaixo do título "Videos".
    END
    AppiumLibrary.Click Element    ${botao_video}

Aguardar vídeo enviado
    [Documentation]    Aguarda o upload do vídeo terminar. O tile do vídeo exibe uma
    ...    nuvem cinza enquanto sobe e uma nuvem verde quando concluído; espera-se
    ...    pela nuvem verde. Re-rola até o tile do vídeo ficar visível.
    BuiltIn.Wait Until Keyword Succeeds    180s    5s    Verificar vídeo enviado

Verificar vídeo enviado
    [Documentation]    Garante o tile do vídeo visível e confirma a nuvem verde.
    Rolar até slot               ${VISTORIA_VIDEO_TILE}
    Aguardar elemento visível    ${VISTORIA_XPATH_VIDEO_NUVEM_VERDE}    3s

Concluir vistoria
    [Documentation]    Rola até o fim da tela de mídias e conclui a vistoria. Re-tenta se a
    ...    tela for redesenhada entre achar o botão e clicar (StaleElementReference).
    BuiltIn.Wait Until Keyword Succeeds    ${DEFAULT_TIMEOUT}s    1s    Clicar em concluir vistoria

Clicar em concluir vistoria
    [Documentation]    Uma tentativa de rolar até o fim e clicar em "Concluir vistoria".
    Rolar tela de mídias até o fim
    Clicar quando visível    ${VISTORIA_BTN_CONCLUIR}    3s

Finalizar vistoria
    [Documentation]    Aguarda a vistoria ficar "Aguardando diagnóstico" (aprovação pela WEB).
    Aguardar elemento visível    ${VISTORIA_TXT_AGUARDANDO_DIAGNOSTICO}

# ---------- Cancelamento e fim do turno ----------
Abandonar vistoria
    [Documentation]    Abandona a vistoria em andamento informando outro motivo.
    Clicar quando visível        ${VISTORIA_TXT_ABANDONAR}
    Clicar quando visível        ${VISTORIA_BTN_OUTRO_MOTIVO}
    Digitar quando visível       ${VISTORIA_INPUT_MOTIVO_ABANDONO}    Sem condições de acesso
    Clicar quando visível        ${VISTORIA_BTN_CONFIRMAR_ABANDONO}

Ficar offline
    [Documentation]    Fica offline ao final do turno e volta à Home.
    Clicar quando visível        ${VISTORIA_BTN_FICAR_OFFLINE}
    Aguardar elemento visível    ${VISTORIA_BTN_INICIAR}

# ---------- Sessão ----------
Preparar sessão de vistoria
    [Documentation]    Abre o app (a orientação é controlada pelo próprio app; a câmera
    ...    vai para paisagem sozinha) e deixa na Home ou em atendimento.
    Abrir aplicativo    no_reset=${True}
    Conceder acesso à câmera se solicitado
    ${welcome}=    Aparece na tela    ${LOGIN_BTN_ACESSAR_CONTA}    15s
    IF    ${welcome}
        Clicar quando visível    ${LOGIN_BTN_ACESSAR_CONTA}
        Preencher campos de Email    ${usuarios}[wily_DA][usuario_app]
        Preencher campos de senha    ${usuarios}[wily_DA][senha_app]
        Clicar em Entrar
        Verificar se o login foi realizado com sucesso
        Conceder acesso à câmera se solicitado
    END
    Wait Until Keyword Succeeds    ${DEFAULT_TIMEOUT}s    2s    Estar na Home ou em atendimento

Estar na Home ou em atendimento
    [Documentation]    Considera pronto quando a Home (botão Iniciar) ou um atendimento
    ...    em andamento ("Caminhe até o local") estiver visível.
    ${home}=     Aparece na tela    ${VISTORIA_BTN_INICIAR}     3s
    ${atend}=    Aparece na tela    ${VISTORIA_ETAPA_CAMINHE}   3s
    IF    not ($home or $atend)
        Registrar estado da tela
    END
    Should Be True    $home or $atend

Registrar estado da tela
    [Documentation]    Loga activity atual, textos visíveis e screenshot, para diagnóstico.
    ${activity}=    Run Keyword And Ignore Error    AppiumLibrary.Get Activity
    Log    Activity: ${activity}[1]    WARN
    ${fonte}=    AppiumLibrary.Get Source
    ${textos}=    Evaluate    __import__('re').findall(r'(?:text|content-desc)="([^"]+)"', $fonte)
    Log    Textos na tela: ${textos}    WARN
    AppiumLibrary.Capture Page Screenshot

Encerrar sessões E2E
    [Documentation]    Encerra a sessão do browser (Web) e do app (Appium). Cada passo é
    ...    tentado separadamente: se um falhar (ou não existir), os outros ainda
    ...    são executados.
    Run Keyword And Ignore Error    SeleniumLibrary.Close All Browsers
    Run Keyword And Ignore Error    AppiumLibrary.Close Application

Iniciar gravação
    [Documentation]    Toca o obturador e confirma que a gravação começou.
    Tocar obturador
    BuiltIn.Sleep    2s
    Registrar estado da tela

Parar gravação
    [Documentation]    Toca o obturador até o botão de confirmar o vídeo aparecer.
    ...    Tenta pelo elemento, e se não funcionar, por coordenada. Até 4 tentativas.
    FOR    ${tentativa}    IN RANGE    4
        ${confirmar}=    Aparece na tela    ${VISTORIA_BTN_CONFIRMAR_FOTO}    2s
        Exit For Loop If    ${confirmar}
        IF    ${tentativa} % 2 == 0
            Run Keyword And Ignore Error    Tocar obturador pelo elemento
        ELSE
            Tocar obturador por coordenada
        END
        BuiltIn.Sleep    2s
    END
    ${confirmar}=    Aparece na tela    ${VISTORIA_BTN_CONFIRMAR_FOTO}    5s
    Should Be True    ${confirmar}    msg=Não consegui parar a gravação: o botão de confirmar não apareceu.

Parar gravação com toque firme
    [Documentation]    Toca no obturador com um toque de 300ms (em vez de toque instantâneo)
    ...    e repete até o cronômetro da gravação sumir (até 3 vezes).
    ${largura}=    AppiumLibrary.Get Window Width
    ${altura}=     AppiumLibrary.Get Window Height
    ${x}=    Evaluate    int(int($largura) * 0.5)
    ${y}=    Evaluate    int(int($altura) * 0.96)
    FOR    ${tentativa}    IN RANGE    3
        &{args}=    Create Dictionary    x=${x}    y=${y}    duration=300
        AppiumLibrary.Execute Script    mobile: longClickGesture    &{args}
        BuiltIn.Sleep    2s
        ${gravando}=    Aparece na tela    xpath=//android.widget.TextView[contains(@text,"00:00:")]    1s
        Exit For Loop If    not ${gravando}
    END

# ---------- Gravação de vídeo ----------
Localizar obturador
    [Documentation]    Retorna as coordenadas (x, y) do centro do obturador, achado pela
    ...    geometria (ViewGroup clicável centralizado e abaixo de 80% da altura).
    ${largura}=    AppiumLibrary.Get Window Width
    ${altura}=     AppiumLibrary.Get Window Height
    @{candidatos}=    AppiumLibrary.Get Webelements    xpath=//android.view.ViewGroup[@clickable="true"]
    FOR    ${el}    IN    @{candidatos}
        ${loc}=    AppiumLibrary.Get Element Location    ${el}
        ${tam}=    AppiumLibrary.Get Element Size        ${el}
        ${cx}=    Evaluate    int($loc['x'] + $tam['width'] / 2)
        ${cy}=    Evaluate    int($loc['y'] + $tam['height'] / 2)
        ${centrado}=    Evaluate    abs($cx - int($largura) / 2) < int($largura) * 0.1
        ${embaixo}=     Evaluate    $cy > int($altura) * 0.8
        IF    ${centrado} and ${embaixo}
            RETURN    ${cx}    ${cy}
        END
    END
    Fail    Obturador não encontrado entre os elementos clicáveis.

Localizar elemento do obturador
    [Documentation]    Retorna o WebElement do obturador (ViewGroup clicável centralizado
    ...    e abaixo de 80% da altura).
    ${largura}=    AppiumLibrary.Get Window Width
    ${altura}=     AppiumLibrary.Get Window Height
    @{candidatos}=    AppiumLibrary.Get Webelements    xpath=//android.view.ViewGroup[@clickable="true"]
    FOR    ${el}    IN    @{candidatos}
        ${loc}=    AppiumLibrary.Get Element Location    ${el}
        ${tam}=    AppiumLibrary.Get Element Size        ${el}
        ${cx}=    Evaluate    int($loc['x'] + $tam['width'] / 2)
        ${cy}=    Evaluate    int($loc['y'] + $tam['height'] / 2)
        ${centrado}=    Evaluate    abs($cx - int($largura) / 2) < int($largura) * 0.1
        ${embaixo}=     Evaluate    $cy > int($altura) * 0.8
        IF    ${centrado} and ${embaixo}
            RETURN    ${el}
        END
    END
    Fail    Obturador não encontrado entre os elementos clicáveis.

Tocar em coordenada
    [Documentation]    Toque na coordenada. Sem duration usa Click A Point (o Appium 1.22
    ...    não tem mobile: clickGesture). Com duration > 0 faz toque longo.
    [Arguments]    ${x}    ${y}    ${duration}=0
    IF    ${duration} > 0
        &{args}=    Create Dictionary    x=${x}    y=${y}    duration=${duration}
        AppiumLibrary.Execute Script    mobile: longClickGesture    &{args}
    ELSE
        AppiumLibrary.Click A Point    ${x}    ${y}    duration=100
    END

Iniciar gravação do vídeo
    [Documentation]    Localiza o obturador, guarda suas coordenadas (para parar depois)
    ...    e inicia a gravação clicando no elemento (igual à foto). Se falhar, toca na
    ...    coordenada.
    TRY
        ${x}    ${y}=    Localizar obturador
    EXCEPT
        Log    Obturador não encontrado pelo XML; usando coordenada aproximada.    WARN
        ${largura}=    AppiumLibrary.Get Window Width
        ${altura}=     Altura do app
        ${x}=    Evaluate    int(int($largura) * 0.5)
        ${y}=    Evaluate    int(int($altura) * 0.96)
    END
    Set Test Variable    ${OBTURADOR_X}    ${x}
    Set Test Variable    ${OBTURADOR_Y}    ${y}
    ${ok}=    Run Keyword And Return Status    Tocar obturador pelo elemento
    IF    not ${ok}
        Tocar em coordenada    ${x}    ${y}
    END

Tentar parar gravação
    [Documentation]    Uma tentativa de parar a gravação, usando uma estratégia diferente
    ...    conforme o número da tentativa.
    [Arguments]    ${tentativa}
    ${estrategia}=    Evaluate    ${tentativa} % 5
    Log    Parando gravação: tentativa ${tentativa + 1}, estratégia ${estrategia}.    WARN
    IF    ${estrategia} == 0
        ${el}=    Localizar elemento do obturador
        AppiumLibrary.Click Element    ${el}
    ELSE IF    ${estrategia} == 1
        ${el}=    Localizar elemento do obturador
        ${id}=    Evaluate    $el.id
        &{args}=    Create Dictionary    elementId=${id}    duration=100
        AppiumLibrary.Execute Script    mobile: longClickGesture    &{args}
    ELSE IF    ${estrategia} == 2
        Tocar em coordenada    ${OBTURADOR_X}    ${OBTURADOR_Y}    300
    ELSE IF    ${estrategia} == 3
        AppiumLibrary.Click A Point    ${OBTURADOR_X}    ${OBTURADOR_Y}    duration=150
    ELSE
        ${y_alto}=    Evaluate    int(${OBTURADOR_Y}) - 40
        Tocar em coordenada    ${OBTURADOR_X}    ${y_alto}    800
    END

Parar gravação do vídeo
    [Documentation]    Tenta parar a gravação com estratégias diferentes (elemento,
    ...    elementId, toque longo, ponto, toque longo mais alto) até o botão de confirmar
    ...    aparecer. Até 8 tentativas.
    FOR    ${tentativa}    IN RANGE    8
        ${confirmar}=    Aparece na tela    ${VISTORIA_BTN_CONFIRMAR_FOTO}    1s
        Exit For Loop If    ${confirmar}
        Run Keyword And Ignore Error    Tentar parar gravação    ${tentativa}
        ${confirmar}=    Aparece na tela    ${VISTORIA_BTN_CONFIRMAR_FOTO}    4s
        Exit For Loop If    ${confirmar}
    END
    ${confirmar}=    Aparece na tela    ${VISTORIA_BTN_CONFIRMAR_FOTO}    3s
    IF    not ${confirmar}
        Registrar estado da tela
    END
    Should Be True    ${confirmar}    msg=Não consegui parar a gravação: o botão de confirmar não apareceu.

Altura do app
    [Documentation]    Altura do app lida do XML (sem barras do sistema).
    ${fonte}=    AppiumLibrary.Get Source
    ${altura}=    Evaluate    int(__import__('re').search(r'<hierarchy[^>]*height="(\d+)"', $fonte).group(1))
    RETURN    ${altura}