package bz.idm.web.task;

import static org.quartz.CronScheduleBuilder.cronSchedule;
import static org.quartz.JobBuilder.newJob;
import static org.quartz.TriggerBuilder.newTrigger;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.Date;
import java.util.Properties;

import javax.servlet.ServletConfig;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.quartz.CronTrigger;
import org.quartz.Job;
import org.quartz.JobDetail;
import org.quartz.JobExecutionContext;
import org.quartz.JobExecutionException;
import org.quartz.Scheduler;
import org.quartz.SchedulerException;
import org.quartz.SchedulerFactory;
import org.quartz.impl.StdSchedulerFactory;

public class CronTask extends HttpServlet {

	Scheduler sched;
	String webinfPath;

	static void runSoapUi(String webinfPath, final OutputStream output) {
		File script_sh = new File(new File(webinfPath), "script.sh");
		try {
			Process process = new ProcessBuilder("bash", script_sh.getAbsolutePath(), "./scriptconfig.txt")
					.directory(new File(webinfPath)).redirectErrorStream(true).start();
			final InputStream pout = process.getInputStream();
			int c;
			while ((c = pout.read()) >= 0) {
				output.write(c);
				output.flush();
			}
			int code = process.waitFor();
		} catch (IOException e) {
			e.printStackTrace();
		} catch (InterruptedException e) {
			e.printStackTrace();
		}
	}

	public static class SouapUiJob implements Job {
		public void execute(JobExecutionContext arg0) throws JobExecutionException {
			String webinfPath = arg0.getJobDetail().getJobDataMap().getString("webinfPath");
			runSoapUi(webinfPath, System.out);
		}
	}

	@Override
	public void init(ServletConfig config) throws ServletException {

		try {
			super.init(config);

			webinfPath = getServletContext().getRealPath("/WEB-INF/");

			Properties p = new Properties();
			p.put("org.quartz.threadPool.threadCount", "1");

			SchedulerFactory sf = new StdSchedulerFactory(p);

			sched = sf.getScheduler();
			JobDetail job = newJob(SouapUiJob.class).usingJobData("webinfPath", webinfPath).build();

			// https://www.freeformatter.com/cron-expression-generator-quartz.html
			// At 03:30:00am every day: 0 30 3 * * ? *
			CronTrigger trigger = newTrigger().withSchedule(cronSchedule("0 30 3 * * ? *")).build();
			Date nextDate = sched.scheduleJob(job, trigger);

			sched.start();

		} catch (SchedulerException e) {
			throw new ServletException(e);
		}
	}

	@Override
	public void destroy() {
		super.destroy();
		try {
			sched.shutdown(true);
		} catch (SchedulerException e) {
			e.printStackTrace();
		}
	}

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		response.setContentType("text/plain");
		runSoapUi(webinfPath, response.getOutputStream());
	}
}
