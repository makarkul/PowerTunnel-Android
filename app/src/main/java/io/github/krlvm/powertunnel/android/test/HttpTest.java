package io.github.krlvm.powertunnel.android.test;

import android.util.Log;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;

public class HttpTest {
    private static final String TAG = "HttpTest";

    public static void testHttp(String urlStr) {
        try {
            URL url = new URL(urlStr);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("GET");
            conn.setInstanceFollowRedirects(false); // Don't follow redirects automatically
            
            Log.i(TAG, "Sending request to: " + urlStr);
            Log.i(TAG, "Response code: " + conn.getResponseCode());
            Log.i(TAG, "Response message: " + conn.getResponseMessage());
            
            // Read response headers
            for (String key : conn.getHeaderFields().keySet()) {
                if (key != null) {
                    Log.i(TAG, "Header: " + key + " = " + conn.getHeaderField(key));
                }
            }
            
            // Read response body
            try (BufferedReader reader = new BufferedReader(new InputStreamReader(conn.getInputStream()))) {
                String line;
                StringBuilder response = new StringBuilder();
                while ((line = reader.readLine()) != null) {
                    response.append(line);
                }
                Log.i(TAG, "Response body: " + response.toString());
            }
            
            conn.disconnect();
        } catch (IOException e) {
            Log.e(TAG, "Error during HTTP request", e);
        }
    }
}
