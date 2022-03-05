using Characters;
using UnityEngine;
using UnityEngine.Networking;
using TMPro;


namespace Main
{
    public class SolarSystemNetworkManager : NetworkManager
    {
        //[SerializeField] private string playerName;
        [SerializeField] private TMP_InputField playerName;
        
        public override void OnServerAddPlayer(NetworkConnection conn, short playerControllerId)
        {
            var spawnTransform = GetStartPosition();

            var player = Instantiate(playerPrefab, spawnTransform.position, spawnTransform.rotation);
            ShipController ship = player.GetComponent<ShipController>();
            ship.gameObject.name = playerName.text;
            ship.OnTrigger += () => ship.GoToStartPosition(spawnTransform);
            NetworkServer.AddPlayerForConnection(conn, player, playerControllerId);

        }

       
        public override void OnStartServer()
        {
            base.OnStartServer();
        }

    }
}
