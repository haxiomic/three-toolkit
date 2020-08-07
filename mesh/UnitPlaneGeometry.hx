package mesh;

class UnitPlaneGeometry extends three.PlaneBufferGeometry {

	public function new() {
		super(1, 1, 1, 1);
	}

	static public final globalGeom = new UnitPlaneGeometry();

}