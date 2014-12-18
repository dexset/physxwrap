import draw.window;
import des.app;

void main()
{
    auto app = new GLApp;
    app.addWindow({ return new MainWindow("test", ivec2(800, 600)); });

    app.run();
    app.destroy();
}
