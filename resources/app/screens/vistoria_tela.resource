*** Settings ***
Documentation     Mapeamento dos elementos da tela de vistoria do app.

*** Variables ***
# Ícone "seta voltar" (Material Design Icons, U+F004D). O Appium Inspector mostra [],
# então o código do caractere é usado direto para não depender de copiar/colar.
${ICONE_SETA_VOLTAR}                 ${{chr(0xF004D)}}

# Tela principal
${VISTORIA_BTN_INICIAR}              xpath=//*[@resource-id="start-button" or @content-desc="Iniciar" or contains(@text, "Iniciar")]

# Início: sem vistorias por perto
${VISTORIA_BTN_FICAR_ONLINE_MESMO_ASSIM}    xpath=//*[contains(@content-desc, "Ficar online mesmo assim") or contains(@text, "Ficar online mesmo assim")]
${VISTORIA_TXT_SEM_ORDENS}           xpath=//*[contains(@text, "ordens de serviço") or contains(@content-desc, "ordens de serviço")]
${VISTORIA_BTN_FECHAR}               xpath=//android.view.ViewGroup[@content-desc="Fechar"]

# Início: com vistorias por perto
${VISTORIA_STATUS_ONLINE}            xpath=//*[contains(@text, "Você está on-line") or contains(@content-desc, "Você está on-line")]
${VISTORIA_OFERTA_TXT_ACEITAR}       xpath=//android.widget.TextView[@text="Aceitar"]
${VISTORIA_OFERTA_SLIDER}            xpath=//android.widget.FrameLayout[@resource-id="android:id/content"]/android.widget.FrameLayout/android.view.ViewGroup/android.view.ViewGroup/android.view.ViewGroup/android.widget.ScrollView/android.view.ViewGroup/android.view.ViewGroup/android.view.ViewGroup/android.widget.ScrollView/android.view.ViewGroup/android.view.ViewGroup/android.view.ViewGroup[3]/android.view.ViewGroup[2]

# Vistoria aceita
${VISTORIA_ETAPA_CAMINHE}            xpath=//android.widget.TextView[@text="Caminhe até o local"]
${VISTORIA_BTN_INICIAR_VISTORIA}     xpath=//android.view.ViewGroup[@content-desc="Iniciar vistoria"]
${VISTORIA_BTN_ENVIAR_FOTOS}         xpath=//android.view.ViewGroup[@content-desc="Enviar fotos"]
${VISTORIA_TITULO_ENVIAR_VISTORIA}   xpath=//*[@text="Enviar vistoria" or @pane-title="Enviar vistoria"]
${VISTORIA_TITULO_PENDENCIAS}        xpath=//*[@text="Pendências da vistoria" or @pane-title="Pendências da vistoria"]
${VISTORIA_BTN_CAMERA}               xpath=//android.view.ViewGroup[contains(@content-desc, "Câmera")]
${VISTORIA_BTN_GRAVAR_VIDEO}         xpath=//*[@resource-id="record-button" or @content-desc="Gravar vídeo"]
${VISTORIA_TEXTO_ZOOM_CAMERA}        xpath=//*[@text="Zoom 1.0x"]
${VISTORIA_BTN_CONFIRMAR_FOTO}       xpath=//*[@resource-id="confirm-media-button"]
${VISTORIA_BTN_CONCLUIR}             xpath=//*[@resource-id="send-inspection-button"]
${ICONE_NUVEM_VERDE}                 ${{chr(0xE2BF)}}
${ICONE_NUVEM_CINZA}                 ${{chr(0xE2C3)}}
${VISTORIA_XPATH_VIDEO_NUVEM_VERDE}  //*[@resource-id="media-Videos-0" and contains(@content-desc, "${ICONE_NUVEM_VERDE}")]
${VISTORIA_VIDEO_TILE}               xpath=//*[@resource-id="media-Videos-0"]
${VISTORIA_ADD_FOTOS_IDEAIS}         xpath=(//android.widget.TextView[@text="Fotos ideais"]/following::android.view.ViewGroup[@resource-id="add-media"])[1]
${VISTORIA_ADD_FOTOS_GUIADAS}        xpath=(//android.widget.TextView[@text="Fotos guiadas"]/following::android.view.ViewGroup[@resource-id="add-media"])[1]
${VISTORIA_FOTO_IDEAL}               xpath=//*[@resource-id="media-free-photo-0"]
${VISTORIA_FOTO_GUIADA}              xpath=//*[@resource-id="media-Fotos guiadas-0"]
${VISTORIA_TXT_UPLOAD_EM_PROGRESSO}  xpath=//*[@text="Upload em progresso" or @content-desc="Upload em progresso"]
${VISTORIA_BTN_AGUARDAR_UPLOAD}      xpath=//*[@resource-id="error-modal-close" or @content-desc="Aguardar upload"]
${VISTORIA_TXT_AGUARDANDO_DIAGNOSTICO}    xpath=//*[@text="Aguardando diagnóstico" or @content-desc="Aguardando diagnóstico"]
# Tela de sucesso exibida no app após a vistoria ser aprovada no WEB
${VISTORIA_TXT_VISTORIA_APROVADA}    xpath=//*[@text="Tudo certo com sua vistoria!" or @content-desc="Tudo certo com sua vistoria!"]
${VISTORIA_BTN_BUSCAR_VISTORIA}      xpath=//*[@resource-id="search-button" or @content-desc="Buscar vistoria"]
${VISTORIA_HOME_BTN_INICIAR}         xpath=//*[@resource-id="start-button"]
${VISTORIA_BTN_PROSSEGUIR_APROVACAO}    xpath=//*[@clickable="true" and (contains(@text,"Continuar") or contains(@content-desc,"Continuar") or contains(@text,"Prosseguir") or contains(@content-desc,"Prosseguir") or contains(@text,"Voltar para início") or contains(@content-desc,"Voltar para início") or contains(@text,"Ir para o início") or contains(@content-desc,"Ir para o início") or contains(@text,"Entendi") or contains(@content-desc,"Entendi"))]
${VISTORIA_ADD_REFERENCIA}           xpath=(//android.widget.TextView[@text="Foto de referencia"]/following::android.view.ViewGroup[@resource-id="add-media"])[1]
${VISTORIA_ADD_APROXIMADA}           xpath=(//android.widget.TextView[@text="Foto aproximada"]/following::android.view.ViewGroup[@resource-id="add-media"])[1]
${VISTORIA_ADD_CENTRALIZADA}         xpath=(//android.widget.TextView[@text="Foto centralizada"]/following::android.view.ViewGroup[@resource-id="add-media"])[1]
${VISTORIA_ADD_ABERTA}               xpath=(//android.widget.TextView[@text="Foto aberta"]/following::android.view.ViewGroup[@resource-id="add-media"])[1]
${VISTORIA_ADD_VIDEO}                xpath=(//android.widget.TextView[@text="Videos" or @text="Vídeos"]/following::android.view.ViewGroup[@resource-id="add-media"])[1]
${VISTORIA_FOTO_REFERENCIA}          xpath=//*[@resource-id="media-Foto de referencia-0"]
${VISTORIA_FOTO_APROXIMADA}          xpath=//*[@resource-id="media-Foto aproximada-0"]
${VISTORIA_FOTO_CENTRALIZADA}        xpath=//*[@resource-id="media-Foto centralizada-0"]
${VISTORIA_FOTO_ABERTA}              xpath=//*[@resource-id="media-Foto aberta-0"]

# Cancelamento
${VISTORIA_BTN_VOLTAR_ETAPA}         xpath=//android.view.ViewGroup[@content-desc="${ICONE_SETA_VOLTAR}"]
${VISTORIA_TXT_ABANDONAR}            xpath=//*[normalize-space(@content-desc)="Abandonar vistoria" or normalize-space(@text)="Abandonar vistoria"]
${VISTORIA_BTN_OUTRO_MOTIVO}         xpath=//android.view.ViewGroup[contains(@content-desc, "Outro")]
${VISTORIA_INPUT_MOTIVO_ABANDONO}    xpath=//android.widget.EditText
${VISTORIA_BTN_CONFIRMAR_ABANDONO}   xpath=//android.view.ViewGroup[@content-desc="Confirmar abandono"]
${VISTORIA_BTN_FICAR_OFFLINE}        xpath=//android.view.ViewGroup[@content-desc="Ficar offline"]
${VISTORIA_BTN_RECUSAR}              id=reject-offer

${VISTORIA_CAMERA_DISPARO_X}    360
${VISTORIA_CAMERA_DISPARO_Y}    1353
${VISTORIA_VIDEO_MINIMO_SEGUNDOS}    16