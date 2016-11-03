package tests.video
{
	import org.flexunit.Assert;

	/**
	 * @author Alan Ross
	 * @version 0.1
	 */
	public final class TestCase1
	{
		public function TestCase1()
		{
		}

		[Test(description="Test description")]
		public function test():void
		{
			var expected:int = 1;
			var result:int = 1;
			Assert.assertEquals( expected, result );
		}

		public function toString():String
		{
			return "[TestCase1]";
		}
	}
}