function onCreatePost()
{
	PlayState.camGame.zoom = 0.65;

	var bricks:SockitSprite = new SockitSprite(0, 0);
	bricks.setImage('stages/stage/stageback');
	bricks.screenCenter();
	bricks.scrollFactor.set(0.9, 0.9);
	add(bricks);

	var floor:SockitSprite = new SockitSprite(0, 0);
	floor.setImage('stages/stage/stagefront');
	floor.y = 700;
	floor.scrollFactor.set(0.9, 0.9);
	add(floor);

	var curtains:SockitSprite = new SockitSprite(0, 0);
	curtains.setImage('stages/stage/stagefront');
	curtains.screenCenter();
	curtains.scrollFactor.set(1.3, 1.3);
	add(curtains);

	bricks.cameras = [PlayState.camGame];
	floor.cameras = [PlayState.camGame];
	curtains.cameras = [PlayState.camGame];
}
