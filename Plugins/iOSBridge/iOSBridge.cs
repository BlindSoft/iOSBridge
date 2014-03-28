using UnityEngine;
using System.Collections;
using System.Runtime.InteropServices;

///////////////////////////////////////////////////////////////
//
// iOS bridge control class for Unity
//
///////////////////////////////////////////////////////////////
public class iOSBridge : MonoBehaviour {

	// Unity finished level loading
	[DllImport ("__Internal")]
	private static extern void iOSBridgeLoadLevelComplete( string levelName );

	// Send message to Unity
	[DllImport ("__Internal")]
	private static extern void iOSBridgeSendMessageToUIKit( string message );

	// Open UIKit frontend and pause Unity
	// data - parameter to be transfered to UIKit
	[DllImport ("__Internal")]
	public static extern void iOSBridgeFinishUnity( string data );

	// Access to shared object
	public static iOSBridge shared {
		get {
			iOSBridge _shared = (iOSBridge)FindObjectOfType(typeof(iOSBridge));
			return _shared;
		}
	}

	// iOSBridge script initialization
	void Start () {
		DontDestroyOnLoad(this);
		iOSBridgeFinishUnity( "Launch" );
	}

	// This method is called from UIKit to load level by name
	public void LoadLevel( string levelName ) {
		
		// Check if Unity Pro
		if (SystemInfo.supportsRenderTextures) {
			StartCoroutine( LoadLevelAsync( levelName ) );
		} else {
			Application.LoadLevel( levelName );
		}
	}

	// This method is Coroutine to load level asyncronously
	private IEnumerator LoadLevelAsync( string levelName ) {
		AsyncOperation async = Application.LoadLevelAsync( levelName );
		// You can use 'iOSBridgeSendMessageToUIKit' to report level loading progress to UIKit
		yield return async;
	}

	// Finished level load
	public void OnLevelWasLoaded( int levelID ) {
		iOSBridgeLoadLevelComplete( Application.loadedLevelName );	
	}

	public void MessageFromiOS( string message ) {
		// Handle Message from iOS there
	}

	// Opens UIKit
	public void OpenUIKit( string data ) {
		if (data == null) data = "";
		iOSBridgeFinishUnity( data );
	}

	// Sends message to Unity
	public void SendMessageToUIKit( string message ) {
		if (message == null) message = "";
		iOSBridgeSendMessageToUIKit( message );
	}
}
