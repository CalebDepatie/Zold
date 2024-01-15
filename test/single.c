// SPDX-FileCopyrightText: 2024 Caleb Depatie
//
// SPDX-License-Identifier: 0BSD

int main() {
    volatile int x = 1;
    x = x << 3;
    x *= 3;

    return 0;
}