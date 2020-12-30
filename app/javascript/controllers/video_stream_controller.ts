import { Controller } from "stimulus";

import "video.js/dist/video-js.min.css";
import videojs from "video.js";
import RecordRTC from "recordrtc";
import "videojs-record/dist/css/videojs.record.css";
import Record from "videojs-record/dist/videojs.record";

export default class extends Controller {
  private videoJSoptions = {
    // video.js options
    controls: true,
    bigPlayButton: false,
    loop: false,
    fluid: false,
    width: 1289,
    height: 720,
    plugins: {
      // videojs-record plugin options
      record: {
        image: false,
        audio: false,
        video: true,
        maxLength: 60 * 5,
        debug: true,
      },
    },
  };

  // static targets = ["output"];

  // declare outputTarget: HTMLElement;

  connect() {
    Record; // Kind of gross, but if you don't reference Record, webpack doesn't seem to actually import it, and the plugin can never be setup

    const player = videojs("blinkingStream", this.videoJSoptions, () => {
      const msg =
        "Using video.js " +
        videojs.VERSION +
        " with videojs-record " +
        videojs.getPluginVersion("record") +
        " and recordrtc " +
        RecordRTC.version;
      videojs.log(msg);
    }) as any;

    player.on("ready", function () {
      player.record().getDevice();
    });

    player.on("deviceReady", function () {
      player.record().start();
    });

    player.on("finishRecord", function () {
      console.log("finished recording: ", (player as any).recordedData);
      (player as any).record().saveAs({ video: "blinking.webm" });
      player.record().reset();
    });
  }
}
