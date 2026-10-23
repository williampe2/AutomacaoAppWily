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
        IF    not ${stale}    RETURN    ${False}
    END
    RETURN    ${False}

Aguardar elemento visível
    [Documentation]    Espera o elemento ficar visível, refazendo a busca a cada tentativa.
    [Arguments]    ${locator}    ${timeout}=${DEFAULT_TIMEOUT}s
    BuiltIn.Wait Until Keyword Succeeds    ${timeout}    1s
    ...    AppiumLibrary.Wait Until Element Is Visible    ${locator}    3s

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
    ${visivel}=    Aparece na tela    ${VISTORIA_BTN_INICIAR_VISTORIA}    2s
    IF    not ${visivel}
        Deslizar para cima    0.8    0.3    ${700}
    END
    Aguardar elemento visível    ${VISTORIA_BTN_INICIAR_VISTORIA}

Iniciar vistoria
    [Documentation]    Inicia a vistoria no atendimento aceito.
    Clicar quando visível        ${VISTORIA_BTN_INICIAR_VISTORIA}
    Aguardar elemento visível    ${VISTORIA_BTN_ENVIAR_FOTOS}

Enviar fotos
    [Documentation]    Abre a tela de envio de mídias da vistoria.
    Clicar quando visível        ${VISTORIA_BTN_ENVIAR_FOTOS}
    Aguardar elemento visível    ${VISTORIA_TITULO_ENVIAR_VISTORIA}

Completar mídias e concluir
    [Documentation]    Preenche as fotos da categoria "Referência" e o vídeo:
    ...    as 3 fotos visíveis ao abrir (referencia, aproximada e centralizada),
    ...    depois rola a tela até o fim e captura a foto aberta e o vídeo.
    Adicionar foto    ${VISTORIA_ADD_REFERENCIA}      ${VISTORIA_FOTO_REFERENCIA}
    Adicionar foto    ${VISTORIA_ADD_APROXIMADA}      ${VISTORIA_FOTO_APROXIMADA}
    Adicionar foto    ${VISTORIA_ADD_CENTRALIZADA}    ${VISTORIA_FOTO_CENTRALIZADA}
    Rolar tela de mídias até o fim
    Adicionar foto    ${VISTORIA_ADD_ABERTA}          ${VISTORIA_FOTO_ABERTA}
    Rolar até slot    ${VISTORIA_ADD_VIDEO}
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
    Deslizar para cima    0.75    0.35    ${600}

Confirmar foto
    [Documentation]    Dispara a câmera (botão central) e confirma a foto capturada.
    [Arguments]    ${foto}
    Aguardar elemento visível    ${VISTORIA_TEXTO_ZOOM_CAMERA}
    Disparar câmera
    Clicar quando visível        ${VISTORIA_BTN_CONFIRMAR_FOTO}
    Aguardar elemento visível    ${foto}

Disparar câmera
    [Documentation]    Toca o botão central (disparo/gravação) da câmera. Não usar o
    ...    botão de inverter câmera. O botão não tem id: usa-se a coordenada central medida.
    ${x}=    Convert To Integer    ${VISTORIA_CAMERA_DISPARO_X}
    ${y}=    Convert To Integer    ${VISTORIA_CAMERA_DISPARO_Y}
    &{args}=    Create Dictionary    x=${x}    y=${y}
    AppiumLibrary.Execute Script    mobile: clickGesture    &{args}

Adicionar foto
    [Documentation]    Abre o modal "Adicionar mídia" pelo botão da categoria, escolhe
    ...    a Câmera, tira e confirma a foto.
    [Arguments]    ${botao_adicionar}    ${foto}
    Clicar quando visível    ${botao_adicionar}
    Abrir câmera pelo modal
    Confirmar foto           ${foto}

Abrir câmera pelo modal
    [Documentation]    No modal "Adicionar mídia", toca em "Câmera" e aguarda a câmera abrir.
    Clicar quando visível        ${VISTORIA_BTN_CAMERA}
    Aguardar elemento visível    ${VISTORIA_TEXTO_ZOOM_CAMERA}

Adicionar vídeo
    [Documentation]    Abre o modal "Adicionar mídia" da seção Vídeos, escolhe a Câmera,
    ...    grava ao menos 16s (o app exige no mínimo 15s) e confirma o vídeo.
    Clicar quando visível    ${VISTORIA_ADD_VIDEO}
    Abrir câmera pelo modal
    Disparar câmera
    BuiltIn.Sleep    ${VISTORIA_VIDEO_MINIMO_SEGUNDOS}s
    Disparar câmera
    Clicar quando visível        ${VISTORIA_BTN_CONFIRMAR_FOTO}
    Aguardar elemento visível    ${VISTORIA_VIDEO_TILE}

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
    [Documentation]    Abre o app preservando a sessão. Se a tela de boas-vindas
    ...                ("Acessar conta") aparecer, entra na Home. Também aceita o caso
    ...                de já haver um atendimento em andamento ("Caminhe até o local").
    Abrir aplicativo    no_reset=${True}
    ${welcome}=    Aparece na tela    ${LOGIN_BTN_ACESSAR_CONTA}    15s
    IF    ${welcome}
        Clicar quando visível    ${LOGIN_BTN_ACESSAR_CONTA}
    END
    Wait Until Keyword Succeeds    ${DEFAULT_TIMEOUT}s    2s    Estar na Home ou em atendimento

Estar na Home ou em atendimento
    [Documentation]    Considera pronto quando a Home (botão Iniciar) ou um atendimento
    ...    em andamento ("Caminhe até o local") estiver visível.
    ${home}=     Aparece na tela    ${VISTORIA_BTN_INICIAR}     3s
    ${atend}=    Aparece na tela    ${VISTORIA_ETAPA_CAMINHE}   3s
    Should Be True    ${home} or ${atend}

Encerrar sessões E2E
    [Documentation]    Encerra a sessão do browser (Web) e do app (Appium). Cada uma é
    ...    tentada separadamente: se uma falhar (ou não existir), a outra ainda é encerrada.
    Run Keyword And Ignore Error    SeleniumLibrary.Close All Browsers
    Run Keyword And Ignore Error    AppiumLibrary.Close Application