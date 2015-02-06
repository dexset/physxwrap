import draw.window;
import des.app;

void main()
{
    auto app = new DesApp;
    app.addWindow({ return new MainWindow("test", ivec2(800, 600)); });

    while( app.step() ){}
    app.destroy();
}
