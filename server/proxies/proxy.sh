DIRECTORY_PATH="$(dirname ${0})"

cd "$(dirname $(readlink -f ${0}))"

source /home/cloud/scripts/main.sh

if [ "$#" -eq 1 ]; then
  SERVER_NAME=$1

  j=$(screen -list | grep -P "[0-9]+\.$SERVER_NAME[ \t]+" | wc -l)

  if [[ $j < 1 ]]; then
    cd ${PROXIES_DIRECTORY}/${SERVER_NAME}

    yes | cp ${OUTPUT_DIRECTORY}/Waterfall.jar ${PROXIES_DIRECTORY}/${SERVER_NAME}

    if ! [[ -e "settings.json" ]]; then
      cp ${CLOUD_DIRECTORY}/scripts/server/proxies/settings.json ${PROXIES_DIRECTORY}/${SERVER_NAME}
    else
      plugins=$(jq .plugins ${CLOUD_DIRECTORY}/scripts/server/proxies/settings.json)
      
      jq ".plugins |= $plugins" settings.json > settings.tmp && mv settings.tmp settings.json
    fi

    plugins=$(jq .plugins[] settings.json)

    yes | rm ${OUTPUT_DIRECTORY}/$plugin/*.jar

    for plugin in $plugins; do
      plugin=${plugin//\"}

      if [[ -e "${OUTPUT_DIRECTORY}/$plugin" ]]; then
        yes | cp ${OUTPUT_DIRECTORY}/$plugin ${PROXIES_DIRECTORY}/${SERVER_NAME}/plugins
      else
        echo -e "${COLOR_RED}Não foi possível localizar o plugin $plugin.${COLOR_RESET}"
      fi
    done

    echo -e "${COLOR_GREEN}Ligando o proxy em $(pwd)...${COLOR_RESET}"
    screen -dmS ${SERVER_NAME} java ${MINECRAFT_JAVA_FLAGS} -Xms128M -Xmx2G -jar Waterfall.jar
  else
    echo -e "${COLOR_YELLOW}Servidor já está ligado.${COLOR_RESET}"
  fi
fi