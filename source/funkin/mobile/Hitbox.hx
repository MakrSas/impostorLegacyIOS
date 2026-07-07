package funkin.mobile;

#if TOUCH_CONTROLS
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.input.FlxInput;
import flixel.input.IFlxInput;
import flixel.math.FlxMath;
import flixel.util.FlxColor;

/**
 * A single on-screen touch lane.
 *
 * It owns a `FlxInput<Int>` whose state (released / just pressed / pressed /
 * just released) is driven every frame from the active touches overlapping it.
 * That `FlxInput` is bound into the note `FlxAction`s of `Controls`
 * (see `Controls.bindHitbox`) so held/sustain notes work, while `justPressed` /
 * `justReleased` transitions fire tap/release callbacks used to dispatch the
 * actual note-hit input events.
 */
class HitboxButton extends FlxSprite
{
	static inline final IDLE_ALPHA:Float = 0.12;
	static inline final PRESSED_ALPHA:Float = 0.45;

	/** Drives the bound note action. */
	public var input:FlxInput<Int>;

	/** Note direction (0 = left, 1 = down, 2 = up, 3 = right). */
	public var noteData:Int;

	/** Called on the frame the lane is first touched. */
	public var onJustPressed:Int->Void = null;

	/** Called on the frame the lane stops being touched. */
	public var onJustReleased:Int->Void = null;

	public function new(x:Float, y:Float, width:Int, height:Int, color:FlxColor, noteData:Int)
	{
		super(x, y);

		this.noteData = noteData;
		input = new FlxInput(noteData);

		makeGraphic(width, height, color);
		alpha = IDLE_ALPHA;
		scrollFactor.set();
		moves = false;
		antialiasing = false;
	}

	override function update(elapsed:Float):Void
	{
		var held:Bool = false;

		for (touch in FlxG.touches.list)
		{
			if (touch.pressed && touch.overlaps(this, camera))
			{
				held = true;
				break;
			}
		}

		if (held)
			input.press();
		else
			input.release();

		if (input.justPressed && onJustPressed != null) onJustPressed(noteData);
		if (input.justReleased && onJustReleased != null) onJustReleased(noteData);

		alpha = FlxMath.lerp(alpha, input.pressed ? PRESSED_ALPHA : IDLE_ALPHA, 0.35);

		super.update(elapsed);
	}

	override function destroy():Void
	{
		onJustPressed = null;
		onJustReleased = null;
		input = null;
		super.destroy();
	}
}

/**
 * The four-lane touch hitbox laid over the play field.
 */
class Hitbox extends FlxTypedSpriteGroup<HitboxButton>
{
	// left, down, up, right (matches note data order)
	static final COLORS:Array<FlxColor> = [FlxColor.PURPLE, FlxColor.CYAN, FlxColor.LIME, FlxColor.RED];

	public var buttons:Array<HitboxButton> = [];

	public function new()
	{
		super();

		final laneWidth:Int = Std.int(FlxG.width / 4);

		for (i in 0...4)
		{
			final button = new HitboxButton(laneWidth * i, 0, laneWidth, FlxG.height, COLORS[i], i);
			buttons.push(button);
			add(button);
		}

		scrollFactor.set();
	}

	/** The lane inputs in note-data order, for `Controls.bindHitbox`. */
	public function getInputs():Array<IFlxInput>
	{
		return [for (button in buttons) button.input];
	}

	override function destroy():Void
	{
		buttons = null;
		super.destroy();
	}
}
#end
