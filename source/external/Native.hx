package external;

class Native
{
	/**
	 * Attempts to retrieve the actual task memory used by the application
	 * 
	 * Will fallback on `0.0` if it is not supported.
	 */
	public static function getTaskMemory()
	{
		// external.memory.Memory pulls in a @:buildXml with a fixed relative path
		// that doesn't resolve for the deeper iOS build tree, so skip it there.
		#if (cpp && !ios)
		return external.memory.Memory.getCurrentUsage();
		#else
		return 0.0;
		#end
	}
}
