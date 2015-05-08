import java.io.File;
import org.apache.tools.ant.Task;

public class FileSize extends Task {

  private String path;
  private long length;


	public void setPath(String path) {
		this.path = path;
	}

	public String getPath() {
		return this.path;
	}

	public void execute() {
		try {
      File file = new File(this.path);
      this.length = file.length();
    } catch (Exception e) {
			System.err.println("Unable to find file "+this.path);
		}
	}
	public static void main(String[] args) {
    FileSize fs = new FileSize();
    fs.execute();
		System.out.println(fs.path+" has length "+fs.length);
	}
}
