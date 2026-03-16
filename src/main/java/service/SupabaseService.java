package service;

import okhttp3.*;
import java.io.IOException;
import java.util.concurrent.TimeUnit;

public class SupabaseService {
    
    // Thông tin dự án của bạn
    private static final String SUPABASE_URL = "https://vwbelsnquxscdbyakyfz.supabase.co/storage/v1/object/violation/";
    private static final String SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ3YmVsc25xdXhzY2RieWFreWZ6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzM0NDc2MzIsImV4cCI6MjA4OTAyMzYzMn0.AMjhbZsSLL2AzCi-Ex1mANYTjV5pQfp-yXWOk4F4x00";

    public static String upload(byte[] imageBytes) {
        OkHttpClient client = new OkHttpClient.Builder()
                .connectTimeout(10, TimeUnit.SECONDS)
                .writeTimeout(30, TimeUnit.SECONDS)
                .build();

        // Tạo tên file ngẫu nhiên theo thời gian
        String fileName = "violation_" + System.currentTimeMillis() + ".jpg";
        String fullUrl = SUPABASE_URL + fileName;
        System.out.println(">>> [Supabase] Attempting upload to: " + fullUrl);

        // Tạo Body chứa dữ liệu ảnh nhị phân
        RequestBody body = RequestBody.create(imageBytes, MediaType.parse("image/jpeg"));
        System.out.println(">>> [Supabase] Image size: " + imageBytes.length + " bytes");

        // Xây dựng yêu cầu POST lên Supabase
        Request request = new Request.Builder()
                .url(fullUrl)
                .post(body)
                .addHeader("apikey", SUPABASE_KEY)
                .addHeader("Authorization", "Bearer " + SUPABASE_KEY)
                .addHeader("Content-Type", "image/jpeg")
                .build();

        try (Response response = client.newCall(request).execute()) {
            if (response.isSuccessful()) {
                System.out.println(">>> [Cloud] Upload thanh cong: " + fileName);
                // Trả về link công khai để có thể xem được trên Dashboard (phải có /public/)
                return "https://vwbelsnquxscdbyakyfz.supabase.co/storage/v1/object/public/violation/" + fileName;
            } else {
                String errorBody = response.body() != null ? response.body().string() : "No error body";
                System.err.println(">>> [Cloud] Loi: " + response.code() + " - " + errorBody);
                return null;
            }
        } catch (IOException e) {
            e.printStackTrace();
            return null;
        }
    }
}
