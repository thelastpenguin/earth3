local cfg = {}
GM.cfg = cfg;

cfg.chunk_size = 16;

cfg.origin = Vector( 0, 0, 0 )--Vector( 186.0, -185.0, -10941.0 )
cfg.blockScale = 1 -- 40;
cfg.renderScale = 40;

cfg.map = 'world'

-- be careful when editing these values as they can break your server if misconfigured.
cfg.loadRadius = 5;
cfg.viewRadius = 5;
cfg.gcRadius = 10;


cfg.chunkInRadius = function( pcx, pcy, pcz, ccx, ccy, ccz, radius )
	return math.Round( math.sqrt( (pcx - ccx)*(pcx-ccx) + (pcy-ccy)*(pcy-ccy) + (pcz-ccz)*(pcz-ccz) ) ) <= radius;
end