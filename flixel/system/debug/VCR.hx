package flixel.system.debug;

#if !FLX_NO_DEBUG
import flash.display.BitmapData;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flixel.FlxG;
import flixel.system.FlxAssets;
import flixel.system.ui.FlxSystemButton;
import flixel.util.FlxColor;
import flixel.util.FlxStringUtil;
import flixel.system.debug.FlxDebugger;
using flixel.system.debug.DebuggerUtil;

@:bitmap("assets/images/debugger/buttons/open.png")
private class GraphicOpen extends BitmapData {}

@:bitmap("assets/images/debugger/buttons/pause.png")
private class GraphicPause extends BitmapData {}

@:bitmap("assets/images/debugger/buttons/record_off.png") 
private class GraphicRecordOff extends BitmapData {}

@:bitmap("assets/images/debugger/buttons/record_on.png")
private class GraphicRecordOn extends BitmapData {}

@:bitmap("assets/images/debugger/buttons/restart.png")
private class GraphicRestart extends BitmapData {}

@:bitmap("assets/images/debugger/buttons/step.png")
private class GraphicStep extends BitmapData {}

@:bitmap("assets/images/debugger/buttons/stop.png")
private class GraphicStop extends BitmapData {}

/**
 * This class contains the record, stop, play, and step 1 frame buttons seen on the top edge of the debugger overlay.
 */
class VCR
{
	/**
	 * Texfield that displays the runtime display data for a game replay
	 */
	public var runtimeDisplay:TextField;
	
	public var runtime:Float = 0;

	public var playbackToggleBtn:FlxSystemButton;
	public var stepBtn:FlxSystemButton;
	public var restartBtn:FlxSystemButton;
	public var recordBtn:FlxSystemButton;
	public var openBtn:FlxSystemButton;

	/**
	 * Creates the "VCR" control panel for debugger pausing, stepping, and recording.
	 */
	public function new(Debugger:FlxDebugger)
	{
		restartBtn = Debugger.addButton(CENTER, GraphicRestart.create(), FlxG.resetState);
		#if FLX_RECORD
		recordBtn = Debugger.addButton(CENTER, GraphicRecordOff.create(), FlxG.vcr.startRecording.bind(true));
		openBtn = Debugger.addButton(CENTER, GraphicOpen.create(), FlxG.vcr.onOpen);
		#end
		playbackToggleBtn = Debugger.addButton(CENTER, GraphicPause.create(), FlxG.vcr.pause);
		stepBtn = Debugger.addButton(CENTER, GraphicStep.create(), onStep);
		
		#if FLX_RECORD
		runtimeDisplay = new TextField();
		runtimeDisplay.height = 10;
		runtimeDisplay.y = -9;
		runtimeDisplay.selectable = false;
		runtimeDisplay.multiline = false;
		runtimeDisplay.embedFonts = true;
		var format = new TextFormat(FlxAssets.FONT_DEBUGGER, 12, FlxColor.WHITE);
		runtimeDisplay.defaultTextFormat = format;
		runtimeDisplay.autoSize = TextFieldAutoSize.LEFT;
		updateRuntime(0);
		
		var runtimeBtn = Debugger.addButton(CENTER);
		runtimeBtn.addChild(runtimeDisplay);
		#end
	}

	#if FLX_RECORD
	/**
	 * Usually called by FlxGame when a requested recording has begun.
	 * Just updates the VCR GUI so the buttons are in the right state.
	 */
	public inline function recording():Void
	{
		recordBtn.changeIcon(GraphicRecordOn.create());
		recordBtn.upHandler = FlxG.vcr.stopRecording;
	}

	/**
	 * Usually called by FlxGame when a requested recording has stopped.
	 * Just updates the VCR GUI so the buttons are in the right state.
	 */
	public inline function stoppedRecording():Void
	{
		recordBtn.changeIcon(GraphicRecordOn.create());
		recordBtn.upHandler = FlxG.vcr.startRecording.bind(true);
	}
	
	/**
	 * Usually called by FlxGame when a replay has been stopped.
	 * Just updates the VCR GUI so the buttons are in the right state.
	 */
	public inline function stoppedReplay():Void
	{
		recordBtn.changeIcon(GraphicRecordOff.create());
		recordBtn.upHandler = FlxG.vcr.startRecording.bind(true);
	}
	
	/**
	 * Usually called by FlxGame when a requested replay has begun.
	 * Just updates the VCR GUI so the buttons are in the right state.
	 */
	public inline function playingReplay():Void
	{
		recordBtn.changeIcon(GraphicStop.create());
		recordBtn.upHandler = FlxG.vcr.stopReplay;
	}
	
	/**
	 * Just updates the VCR GUI so the runtime displays roughly the right thing.
	 */
	public function updateRuntime(Time:Float):Void
	{
		runtime += Time;
		runtimeDisplay.text = FlxStringUtil.formatTime(Std.int(runtime / 1000), true);
		if (!runtimeDisplay.visible)
		{
			runtimeDisplay.visible = true;
		}
	}
	#end

	/**
	 * Called when the user presses the Pause button.
	 * This is different from user-defined pause behavior, or focus lost behavior.
	 * Does NOT pause music playback!!
	 */
	public inline function onPause():Void
	{
		playbackToggleBtn.upHandler = FlxG.vcr.resume;
		playbackToggleBtn.changeIcon(GraphicArrowRight.create());
	}

	/**
	 * Called when the user presses the Play button.
	 * This is different from user-defined unpause behavior, or focus gained behavior.
	 */
	public inline function onResume():Void
	{
		playbackToggleBtn.upHandler = FlxG.vcr.pause;
		playbackToggleBtn.changeIcon(GraphicPause.create());
	}

	/**
	 * Called when the user presses the fast-forward-looking button.
	 * Requests a 1-frame step forward in the game loop.
	 */
	public function onStep():Void
	{
		if (!FlxG.vcr.paused)
		{
			FlxG.vcr.pause();
		}
		FlxG.vcr.stepRequested = true;
	}
}
#end
