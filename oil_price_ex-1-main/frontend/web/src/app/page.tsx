"use client";
import React, { useState } from "react";

export default function Home() {
  const [date, setDate] = useState("");
  const [result, setResult] = useState<null | { price: number; currency: string }>(null);
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setResult(null);
    setError(null);
    setLoading(true);

    try {
      const res = await fetch("http://localhost:8000/api/streaming_service", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ service_date: date }),
      });

      const data = await res.json();
      if (data.status) {
        setResult({ price: data.price, currency: data.currency });
      } else {
        setError(data.detail ? JSON.stringify(data.detail) : data.error || "Unknown error");
      }
    } catch (err) {
      setError("Network error");
    }
    setLoading(false);
  };

  return (
    <main className="min-h-screen bg-purple-50 flex items-center justify-center px-4">
      <div className="bg-white shadow-xl rounded-xl p-8 w-full max-w-md border border-purple-200">
        <h2 className="text-2xl font-bold text-center mb-6 text-purple-800">
          ทำนายราคาบริการ Streaming
        </h2>
        <form onSubmit={handleSubmit} className="flex flex-col gap-4">
          <label className="text-sm font-medium text-purple-700">
            เลือกวันที่ (YYYY-MM-DD):
            <input
              type="date"
              value={date}
              onChange={(e) => setDate(e.target.value)}
              required
              className="w-full mt-1 px-3 py-2 border border-purple-300 rounded-md shadow-sm focus:outline-none focus:ring-2 focus:ring-purple-300"
            />
          </label>
          <button
            type="submit"
            disabled={loading}
            className={`w-full py-2 px-4 rounded-md font-semibold text-white transition ${
              loading
                ? "bg-purple-300 cursor-not-allowed"
                : "bg-purple-600 hover:bg-purple-700"
            }`}
          >
            {loading ? "กำลังทำนาย..." : "ทำนายราคา"}
          </button>
        </form>

        {result && (
          <div className="mt-6 p-4 bg-purple-100 border border-purple-300 rounded-md text-purple-800">
            <b>ราคาคาดการณ์:</b> {result.price} {result.currency}
          </div>
        )}

        {error && (
          <div className="mt-6 p-4 bg-red-100 border border-red-300 rounded-md text-red-800">
            <b>เกิดข้อผิดพลาด:</b> {error}
          </div>
        )}
      </div>
    </main>
  );
}
