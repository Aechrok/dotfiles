


WELCOME_TEXT='Wait for the migrator to check for installed Addigy Products'
WELCOME_TITLE="CoreWeave Migration"
DEP_N_DEBUG="/var/tmp/debug_depnotify.log"
DEP_N_APP="/Applications/Utilities/DEPNotify.app"
DEP_N_LOG="/var/tmp/depnotify.log"



caffeinate -d -i -m -u &
caffeinatePID=$!

if [ -d '/Applications/Utilities/DEPNotify.app' ]; then
    continue
else
    curl --silent --output /tmp/DEPNotify-1.1.6.pkg "https://s3.amazonaws.com/nomadbetas/DEPNotify-1.1.6.pkg" >/dev/null
    installer -pkg /tmp/DEPNotify-1.1.6.pkg -target /
fi

touch "$DEP_N_DEBUG"
touch "$DEP_N_LOG"

echo "Command: WindowTitle: $WINDOW_TITLE" >>"$DEP_N_LOG"
echo "Command: MainTitle: $WELCOME_TITLE" >>"$DEP_N_LOG"
echo "Command: MainText: $WELCOME_TEXT" >>"$DEP_N_LOG"
echo "Status: Searching for MDM Profiles" >>"$DEP_N_LOG"
echo "Command: WindowStyle: ActivateOnStep" >>"$DEP_N_LOG"

FINDER_PROCESS=$(pgrep -l "Finder")
until [ "$FINDER_PROCESS" != "" ]; do
    echo "$(date "+%Y-%m-%d %H:%M:%S"): Finder process not found. User session not active." >>"$DEP_N_DEBUG"
    sleep 1
    FINDER_PROCESS=$(pgrep -l "Finder")
done

ACTIVE_USER=$(/usr/bin/stat -f%Su /dev/console)

sudo -u "$ACTIVE_USER" open -a "$DEP_N_APP" --args -path "$DEP_N_LOG"

echo "Status: Finished installing MDM Profile. Closing in 5" >>"$DEP_N_LOG"
sleep 1
echo "Status: Finished installing MDM Profile. Closing in 4" >>"$DEP_N_LOG"
sleep 1
echo "Status: Finished installing MDM Profile. Closing in 3" >>"$DEP_N_LOG"
sleep 1
echo "Status: Finished installing MDM Profile. Closing in 2" >>"$DEP_N_LOG"
sleep 1
echo "Status: Finished installing MDM Profile. Closing in 1" >>"$DEP_N_LOG"
sleep 1
echo "Command: Quit" >>"$DEP_N_LOG"

if ls /var/tmp/depnotify* 1> /dev/null 2>&1; then
    rm /var/tmp/depnotify* >/dev/null 2>&1
    rm /var/tmp/com.depnotify.* >/dev/null 2>&1
    rm /Users/"$ACTIVE_USER"/Library/Preferences/menu.nomad.DEPNotify* >/dev/null 2>&1
killall cfprefsd

exit 0