# Access All-Hardware Service in Your CI/CD Workflow

> This document contains a guide for running firmware on the remote device as part of your CI process.

CI/CD techniques are coming to the embedded world and now the [All-Hardware](https://all-hw.com/) service is enabling remote access to the newest [Ensemble E7](https://www.alifsemi.com/products/) development board as well as other types of popular development [boards](https://all-hw.com/app/index.html#/hardware).

The Ensemble™ processor family is built on the latest generation embedded processing technology that scales from a single Arm® Cortex®-M55 microcontroller (MCU) to a new class of multi-core devices — fusion processors — that blend up to two Cortex-M55 MCU cores, up to two Cortex-A32 microprocessor (MPU) cores capable of running high-level operating systems, and up to two Arm Ethos™-U55 microNPUs for AI/ML acceleration


This demo is intended to show how to speed-up the process of the embedded firmware development by using automation for the firmware testing on cloud hardware.

Here we'll run a simple echo application on a single Cortex-M55 core of Ensemble DevKit-E7 development board using GitHub Actions and REST requests wrapped with the shell scripts. Using this guide you can also run your firmware on any other supported [board](https://all-hw.com/app/index.html#/hardware).


> For the time being this demo is using precompiled examples. To get the source code of the examples please contact [AlifSemiconductor](https://www.alifsemi.com/). Once the source code is available to the public this demo will be updated with detailed instructions for getting the code and building the project.

## Getting the CI/CD Access

Please visit All-Hardware's [board selector page](https://all-hw.com/app/#/hardware) and choose the Ensemble DevKit board, then press "Get CI/CD access" button.

![board selection](https://github.com/all-hw/ci-demo/raw/main/docs/book_the_board.png)

You will get an API key which you'll need later to access the board. For this demo we'll use the key **ba1e491b-331b-4e35-b799-f714b8505843**.

## Quick Look at the Demo Content

The [DEMO project](https://github.com/all-hw/ci-demo.git) contains:

* UART echo example application
* TFLite microspeech example application
* Scripts to upload firmware binaries to the All-Hardware service
* GitHub CI workflow configuration

Ok, great! Let's flash our simple applications to the cloud hardware.

## Flash MCU with GitHub CI

With GitHub Actions you can easily build your CI workflow and the [All-Hardware](https://all-hw.com/) service will support your embedded development process!

Open the [demo GitHub page](https://github.com/all-hw/ci-demo) and fork the repository:

![fork|690x313](https://github.com/all-hw/ci-demo/raw/main/docs/fork.png)

Now you have a fork of the CI demo repository on your account on GitHub. Lets try out the CI workflow:

![start_workflow|690x253](https://github.com/all-hw/ci-demo/raw/main/docs/start_workflow.png)

Congratulations! Your project was successfully built and run on the latest [AlifSemiconductor](https://www.alifsemi.com/) Ensemble DevKit-E7 development board!

![workflow_passed|624x500](https://github.com/all-hw/ci-demo/raw/main/docs/workflow_passed.png)

Now let's take a quick look at the workflow configuration file:

```yaml
name: ALL-HW ALIF CI

on:
  # Manually triggered workflow
  workflow_dispatch:
    inputs:
      binary:
        description: 'Firmware binary to flash to the MCU'
        default: 'bin/HelloW.axf'
        required: true

      file:
        description: 'Input data for the task'
        default: 'test_data/uart_input.txt'
        required: true
      api_key:
        description: 'API key for the board on all-hw.com service'
        default: 'ba1e491b-331b-4e35-b799-f714b8505843'
        required: true
      timeout:
        description: 'Firmware task timeout before abort'
        default: '10'
        required: true

jobs:
  build_and_run:
    runs-on: ubuntu-20.04
    steps:
    # checking out our repository
    - name: Check out repository
      uses: actions/checkout@v2
      with:
        submodules: recursive

    # using the parameters provided above we call
    # All-Hardware GitHub actions
    # to upload your firmware to the cloud hardware
    - name: Run firmware upload to All-Hardware
      id: task
      uses: all-hw/uart-task@main
      with:
        binary: ./${{ github.event.inputs.binary }}
        uart-in: ./${{ github.event.inputs.file }}
        api-key: ${{ github.event.inputs.api_key }}
        timeout: ${{ github.event.inputs.timeout }}
      timeout-minutes: 1

    - name: Getting the Status
      run: echo "${{ steps.task.outputs.status }}"

    - name: Getting the UART output
      run: echo "${{ steps.task.outputs.uart-out }}"

    - name: Getting the execution result code
      run: echo "${{ steps.task.outputs.result-code }}"
```

Firmware upload is done by [All-Hardware GitHub Actions](https://github.com/all-hw/uart-task). You can easily integrate this into your own CI workflow.

## Flash MCU with REST API

We've wrapped the API requests with shell scripts for this examples. Check out the [REST API description](#REST-API-description).

_Requirements: git, curl, jq_

Clone the demo from Github repository:
```bash
git clone https://github.com/all-hw/ci-demo.git
```

Modify the _$API_KEY_ variable in the file _scripts/ci_sampe.sh_ to the API key you received when booking the board.

### Echo Application

Run the following command to upload the Echo example to the All-Hardware remote board:

```bash
./scripts/ci_sample.sh task bin/HelloW.axf test_data/uart_input.txt
```

This will flash the firmware binary from **bin/HelloW.axf** and pass the content of _test_data/uart_input.txt_ to the microcontroller's UART input. Here is the example output:

`7b00ab0c-8566-46ae-ada8-45bc2bdc81d4`

This is a task UUID, you can use it to get the status of the operation:

```bash
./scripts/ci_sample.sh status 7b00ab0c-8566-46ae-ada8-45bc2bdc81d4
```

The response should look like:

```text
Status: finished
Exit code: 156
UART output:

-- Remote service test application - echo test --
test1...
test2...
test3...
Hello World!!!
```


### Microspeech Application

Microspeech source code is available on [Alif's GitHub page](https://github.com/arashed-alif/VHT-TFLmicrospeech). You can get the source code using the following commands:

```text
git clone https://github.com/arashed-alif/VHT-TFLmicrospeech
cd VHT-TFLmicrospeech
git checkout Platform_Alif_Ensemble
```

We already built the example so you can just run it on remote hardware without compiling from source yourself. Make sure you've set the API_KEY variable as described in the previous example, then run following command:

```bash
./scripts/ci_sample.sh task bin/microspeech.axf test_data/empty.txt
```

Then request the status of the operation:
```bash
./scripts/ci_sample.sh status b2dc9f02-5829-11ec-bf2c-67fc59cf5b2a
```

The response should look like:

```text
Executing bin/microspeech.axf on https://cloud.all-hw.com/ci with timeout 10s
Waiting for result... 8a668658-a764-4a15-b71f-afb6c8bdaece
Result code: 156
UART output: =================VVVVVVVVVVVVV=================================
UART is enabled.
Heard silence (153) @400ms
Heard yes (158) @1200ms
Heard unknown (141) @5100ms
Heard no (141) @6100ms
..... more lines here ......

==============================^^^^^^^^^^^^^=================================
```


## REST API Description

### Flashing the Firmware

To flash the device, you'll need to POST the following JSON
```json
{
  "firmware": "......", <-- your firmware here
  "input": "........" <-- input data to send to UART
}
```
to `https://cloud.all-hw.com/ci/usertask?version=V3&rate=115200&log=0&timeout=10&key=<your_api_key>`.

As a response you'll get the UUID of the created task.


### Getting the Operation Status

GET https://cloud.all-hw.com/ci/usertask?id=<task_id>

The response to the task status request is a JSON. The fields are described in the table below.

|Field name|Type|Comment|
| --- | --- | --- |
|status| String | <ul><li>_queued_ – The task is registered on the CI server, but has not been started yet for some reason (for example, there are no free boards).</li>       <li>_running_ – The task script has started on the terminal, but has not finished yet.</li>          <li>_finished_ – The task has terminated on the terminal, or an error has occurred that does not allow the script to run on the terminal.</li></ul>|
|created|Date/time| The time when the task was registered on the CI server.|
|started|Date/time| The time when the task started on the terminal, or an error preventing it from running was encountered.|
|finished|Date/time| The time when the task has completed its work on the terminal, or an error preventing it from running was encountered.|
|code|Int| The return code of the task: <ul><li>_null_ - The task is not finished.</li> <li>_255_ - The task could not be started normally on the terminal.</li></ul>|
|output|String| The output of the task: <ul><li>It will be null if the status field is not finished.</li> <li>It will be the final output of the task if the status field is finished.</li></ul>|
|reservation|Int| The reservation ID on the All-HW server. This can be useful for diagnosing some problems with the task. For example, you can use it to find out which specific board from the group was booked to complete the task.|
